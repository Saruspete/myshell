#
# Origin: https://gitlab.com/bersace/powerline.bash/tree/master
#
# Merge of https://github.com/b-ryan/powerline-shell/ and
# https://github.com/skeswa/prompt .

# Fonts:
# Gentoo: Require media-fonts/powerline-symbols
# Other:
#   git clone https://github.com/powerline/fonts --depth=1
#   cd fonts
#   ./install.sh

#
# Configuration:
#
# POWERLINE_SEGMENTS="pwd venv git"
# POWERLINE_STYLE="default" or your
# POWERLINE_SEP=''
# POWERLINE_THINSEP=''
#
# These variables can be set per shell, without export.
__default_sep=''
__default_thinsep=''

# This value is used to hold the return value of the prompt sub-functions. This
# hack avoid calling functions un subprocess to get ret from stdout.
__powerline_retval=""

function __powerline_split {
	typeset sep="$1"
	typeset str="$2"
	typeset OIFS="${IFS}"
	IFS="$sep"
	__powerline_retval=(${str})
	IFS="${OIFS}"
}

# Gets the current working directory path, but shortens the directories in the
# middle of long paths to just their respective first letters.
function __powerline_shorten_dir {
	# Break down the typeset variables.
	typeset short_pwd
	typeset dir="$1"

	__powerline_split / "${dir##/}"
	typeset dir_parts=("${__powerline_retval[@]}")
	typeset number_of_parts=${#dir_parts[@]}

	# If there are less than 6 path parts, then do no shortening.
	if [[ "$number_of_parts" -lt "5" ]]; then
		__powerline_retval="${dir}"
		return
	fi
	# Leave the last 2 part parts alone.
	typeset last_index="$(( $number_of_parts - 3 ))"
	typeset short_pwd=""

	# Check for a leading slash.
	if [[ "${dir:0:1}" == "/" ]]; then
		# If there is a leading slash, add one to `short_pwd`.
		short_pwd+='/'
	fi

	for i in "${!dir_parts[@]}"; do
		# Append a '/' before we do anything (provided this isn't the first part).
		if [[ "$i" -gt "0" ]]; then
			short_pwd+='/'
		fi

		# Don't shorten the first/last few arguments - leave them as-is.
		if [[ "$i" -lt "2" || "$i" -gt "$last_index" ]]; then
			short_pwd+="${dir_parts[i]}"
		else
			# This means that this path part is in the middle of the path. Our logic
			# dictates that we shorten parts in the middle like this.
			short_pwd+="${dir_parts[i]:0:1}"
		fi
	done

	# Return the resulting short pwd.
	__powerline_retval="$short_pwd"
}

# Parses git status --porcelain=v2 output in an array
function __powerline_parse_git_status_v2 {
	typeset status="$1"
	# branch infos as returned by status : sha, name, upstream, ahead/behind
	typeset branch_infos=()
	typeset sha
	typeset dirty=
	typeset ab
	typeset detached=

	while read line ; do
		# If line starts with '# ', it's branch info
		if [ -z "${line### branch.*}" ] ; then
			branch_infos+=("${line#\# branch.* }")
		else
			# Else, it's a changes. The worktree is dirty
			dirty=1
			break
		fi
	done <<< "${status}"

	# Try to provide a meaningful info if we are not on a branch.
	if [ "${branch_infos[1]}" == "(detached)" ] ; then
		detached=1
		if desc="$(git describe --tags --abbrev=7 2>/dev/null)" ; then
			branch="${desc}"
		else
			# Au pire des cas, utiliser la SHA du commit courant.
			branch="${branch_infos[0]:0:7}"
		fi
	else
		branch="${branch_infos[1]}"
	fi

	ab="${branch_infos[3]-}"
	__powerline_retval=("${branch}" "${dirty}" "${ab}" "${detached}")
}

# Analyser la sortie v1 de git status --porcelain
function __powerline_parse_git_status_v1 {
	typeset status="$1"

	typeset branch
	typeset detached=
	typeset dirty=

	__powerline_split $'\n' "$status"
	typeset lines=("${__powerline_retval[@]}")

	for line in "${lines[@]}" ; do
		if [ "${line}" = "## HEAD (no branch)" ] ; then
			detached=1
			if desc="$(git describe --tags --abbrev=7 2>/dev/null)" ; then
				branch="${desc}"
			else
				# Au pire des cas, utiliser la SHA du commit courant.
				branch="$(git rev-parse --short HEAD)"
			fi
		elif [ -z "${line####*}" ] ; then
			__powerline_split '...' "${line#### }"
			branch="${__powerline_retval[0]}"
		else
			# Les autres lignes sont des lignes de modification.
			dirty=1
			break
		fi
	done

	# On bidonne l'état de synchronisation, faut d'information dans git status.
	typeset ab="+0 -0"

	__powerline_retval=("${branch}" "${dirty}" "${ab}" "${detached}")
}

# Sélectionner le format de git status à analyser
__powerline_git_version="$(git --version 2>/dev/null)"
__powerline_git_version="${__powerline_git_version#git version }"

# la V2 affiche en une commande l'état de synchronisation.
if printf "2.11.0\n%s" "${__powerline_git_version}" | sort --version-sort --check=quiet ; then
	__powerline_git_cmd=(git status --branch --porcelain=v2)
	__powerline_git_parser=__powerline_parse_git_status_v2
else
	__powerline_git_cmd=(git status --branch --porcelain)
	__powerline_git_parser=__powerline_parse_git_status_v1
fi


function __powerline_get_foreground {
	typeset R=$1
	typeset G=$2
	typeset B=$3

	# Les terminaux 256 couleurs ont 6 niveaux pour chaque composant. Les
	# valeurs réelles associées aux indices entre 0 et 5 sont les suivantes.
	typeset values=(0 95 135 175 215 255)
	# Indice de luminosité entre 0 et 9 calculé à partir des composants RGB.
	typeset luminance
	# On associe une couleur de texte pour chaque niveau de luminosité entre 0
	# et 9. Du gris clair au gris foncé en passant par blanc et noir.
	typeset foregrounds=(252 253 253 255 255 16 16 235 234 234)

	# cf. https://fr.wikipedia.org/wiki/SRGB#Caract%C3%A9ristiques_principales
	luminance=$(((${values[${R}]} * 2126 + ${values[${G}]} * 7152 + ${values[${B}]} * 722) / 280000))

	# Tronquer la partie décimale et assurer le 0 initial.
	LC_ALL=C printf -v luminance "%.0f" $luminance

	# Récupérer la couleur de texte selon la luminosité
	__powerline_retval=${foregrounds[$luminance]}

	# Afficher le résultat pour test visuel.
	if [ -n "${DEBUG-}" ] ; then
		fg=${__powerline_retval}
		bg=$((16 + 36 * R + 6 * G + B))
		fgbg="$fg/$bg"
		text="${LOGNAME}@${HOSTNAME}"
		printf "\e[38;5;${fg};48;5;${bg}m $text \e[0m RGB=%s L=%d %7s" "${RGB}" $luminance $fgbg
	fi
}


###############################################################################
# Segments: shortname to designate a part of the pompt.
# Must be functions prefixed by "__powerline_segment_"
#
# `<t|p>:<bg_color>:<fg_color>:<text>`. Chaque chaîne correspond à un segment.

function __powerline_segment_time {
	#typeset text="$(date +%H:%M:%S)"
	typeset text="\t"
	typeset bg=237 fg=250

	__powerline_retval=("p:48;5;${bg}:38;5;${fg}:${text}")
}


function __powerline_segment_hostname {

	typeset bg rgb fg text hash

	if [ -z "${HOSTNAME-}" -a -f /etc/hostname ] ; then
		read HOSTNAME < /etc/hostname
	fi
	USER="${USER-${USERNAME-${LOGNAME-}}}"
	# N'appeler whoami qui si besoin
	if [ -z "${USER}" ] ; then
		USER=$(whoami)
	fi

	text="${USER}@${HOSTNAME-*unknown*}"

	# Calculer la couleur à partir du texte à afficher.
	hash=$(sum <<< "${text}")
	bg=$((1${hash// /} % 215))
	rgb=($((bg / 36)) $(((bg % 36) / 6)) $((bg % 6)))
	bg=$((16+bg))

	# Assurer la lisibilité en déterminant la couleur du texte en fonction de la
	# clareté du fond.
	__powerline_get_foreground "${rgb[@]}"
	fg=${__powerline_retval}

	__powerline_retval=("p:48;5;${bg}:38;5;${fg}:${text}")
}

function __powerline_segment_pwd {
	typeset colors
	typeset next_sep
	typeset short_pwd

	__powerline_shorten_dir "$(dirs +0)"
	typeset short_pwd="${__powerline_retval}"

	__powerline_split / "${short_pwd}"
	typeset parts=("${__powerline_retval[@]}")

	__powerline_retval=()
	typeset sep=p
	for part in "${parts[@]}" ; do
		if [ "${part}" = '~' -o "${part}" = "" ] ; then
			colors="48;5;31:38;5;15"
			next_sep=p
		else
			colors="48;5;237:38;5;250"
			# Les segments suivants auront un séparateur léger
			next_sep=t
		fi
		__powerline_retval+=("${sep}:${colors}:${part}")
		sep=${next_sep}
	done
}

function __powerline_segment_venv {
	if [[ -z "${VIRTUAL_ENV-}" ]]; then
		__powerline_retval=()
		return
	fi

	__powerline_retval=("p:48;5;35:38;5;0:${VIRTUAL_ENV##*/}")
}

function __powerline_segment_status {
	typeset ec=$1

	if [[ $ec -eq 0 ]]; then
		__powerline_retval=()
		return
	fi

	# Mettre en gras avec ;1
	__powerline_retval=("p:48;5;1:38;5;234;1:✘ $ec")
}

function __powerline_segment_git {
	typeset branch
	typeset branch_colors
	typeset ab
	typeset ab_segment=''
	typeset detached

	if ! status="$(LC_ALL=C.UTF-8 ${__powerline_git_cmd[@]} 2>/dev/null)" ; then
		__powerline_retval=()
		return
	fi
	$__powerline_git_parser "${status}"
	branch="${__powerline_retval[0]}"
	ab="${__powerline_retval[2]}"
	detached="${__powerline_retval[3]}"

	# Colorer la branche selon l'existance de modifications.
	if [ -n "${__powerline_retval[1]}" ] ; then
		branch_colors="48;5;161:38;5;15"
	else
		branch_colors="48;5;148:38;5;0"
	fi

	__powerline_retval=("p:${branch_colors}:${detached:+⚓ }${branch}")

	# Compute ahead/behind segment
	if [ -n "${ab##+0*}" ] ; then
		# No +0, the typeset branch is ahead upstream.
		ab_segment="⬆"
	fi
	if [ -n "${ab##+* -0}" ] ; then
		# No -0, the typeset branch is behind upstream.
		ab_segment+="⬇"
	fi
	if [ -n "${ab_segment}" ] ; then
		__powerline_retval+=("p:48;5;240:38;5;250:${ab_segment}")
	fi
}


# A render function is a bash function starting with `__powerline_render_`. It puts
# a PS1 string in `__powerline_retval`.

function __powerline_render_default {
	typeset bg=''
	typeset fg
	typeset ps=''
	typeset segment
	typeset text
	typeset separator

	for segment in "${__powerline_segments[@]}" ; do
		__powerline_split ':' "${segment}"
		typeset infos=("${__powerline_retval[@]}")

		typeset old_bg=${bg-}
		# Recoller les entrées 2 et suivantes avec :
		printf -v text ":%s" "${infos[@]:3}"
		text=${text:1}
		# Nettoyer le \n ajouté par <<<
		text="${text##[[:space:]]}"
		text="${text%%[[:space:]]}"
		# Sauter les segments vides
		if [ -z "${text}" ] ; then
			continue
		fi

		# D'abord, afficher le chevron avec la transition de fond.
		bg=${infos[1]%%:}
		fg=${infos[2]%%:}
		if [ -n "${old_bg}" ] ; then
			if [ "${infos[0]}" = "t" ] ; then
				# Séparateur léger, même couleurs que le texte
				separator=${POWERLINE_THINSEP-$__default_thinsep}
				colors="${fg};${bg}"
			else
				separator=${POWERLINE_SEP-$__default_sep}
				colors="${old_bg/48;/38;};${bg}"
			fi
			ps+="\[\e[${colors}m\]${separator}"
		fi
		# Ensuite, afficher le segment, coloré
		ps+="\[\e[${bg}m\e[${fg}m\] ${text} "
	done

	# Afficher le dernier chevron, transition du fond vers rien.
	old_bg=${bg-}
	bg='49'
	if [ -n "${old_bg}" ] ; then
		ps+="\[\e[${old_bg/48;/38;}m\e[${bg}m\]${POWERLINE_SEP-${__default_sep}}"
	fi

	# Retourner l'invite de commande
	__powerline_retval="${ps}"
}


# Show dollar line.
function __powerline_dollar {
	typeset fg
	typeset last_exit_code=$1
	# Déterminer la couleur du dollar
	if [ $last_exit_code -gt 0 ] ; then
		fg=${ERROR_FG-"1;38;5;161"}
	else
		fg=0
	fi
	# Afficher le dollar sur une nouvelle ligne, pas en mode powerline
	__powerline_retval="\[\e[${fg}m\]\\\$\[\e[0m\] "
}

function __update_ps1 {
	typeset last_exit_code=${1-$?}
	typeset __powerline_segments=()

	# Détecter si on est connecté sur une autre machine ou un autre utilisateur.
	typeset other=${SSH_CLIENT-${SUDO_USER-${MYS_RUNENV-}}}
	typeset segments=${POWERLINE_SEGMENTS-${other:+hostname} time pwd venv git status}
	typeset segment
	for segment in ${segments} ; do
		__powerline_segment_${segment} $last_exit_code
		__powerline_segments+=("${__powerline_retval[@]}")
	done

	typeset __ps1=""
	__powerline_render_${POWERLINE_STYLE-default}
	__ps1+="${__powerline_retval}"
	__powerline_dollar $last_exit_code
	__ps1+="\n${__powerline_retval}"
	PS1="${__ps1}"
}

# Integrrate with myshell
mys_promptfunc_register __update_ps1

