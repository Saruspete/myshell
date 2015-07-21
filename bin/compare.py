
#!/usr/bin/env python
# Name:     compare.py
# Purpose:  Compare File Informaation
# By:       Jerry Gamblin
# Date:     18.07.15
# Modified  18.07.15
# Rev Level 0.1
# -----------------------------------------------

import os
import stat  
import time
import hashlib
import sys

colorred = "\033[01;31m{0}\033[00m"
colorgrn = "\033[1;36m{0}\033[00m"

#Get Files To Compare
if len(sys.argv) != 3:
    print("Error: specify 2 files!")
    exit(0)

file_name  = sys.argv[1]
file_name2 = sys.argv[2]

file_stats = os.stat(file_name)

#File 1
# create a dictionary to hold file info
file_info = {
   'fname': file_name,
   'fsize': round((file_stats [stat.ST_SIZE] / 1024) /1024.0, 2),
   'f_lm': time.strftime("%m/%d/%Y %I:%M:%S %p",time.localtime(file_stats[stat.ST_MTIME])),
   'f_la': time.strftime("%m/%d/%Y %I:%M:%S %p",time.localtime(file_stats[stat.ST_ATIME])),
   'f_ct': time.strftime("%m/%d/%Y %I:%M:%S %p",time.localtime(file_stats[stat.ST_CTIME]))

}

md5 = hashlib.md5(open(file_name, 'rb').read()).hexdigest() 
sha256 = hashlib.sha256(open(file_name, 'rb').read()).hexdigest()

print "File Size     = %(fname)s" % file_info
print "File Size     = %(fsize)s Megabytes" % file_info
print "Last Modified = %(f_lm)s" % file_info
print "Last Accessed = %(f_la)s" % file_info
print "Creation Time = %(f_ct)s" % file_info
print "MD5 Hash      = %s" % md5
print "SHA 256 Hash  = %s" % sha256
print '\n'
#File 2
# create a dictionary to hold file info
file_info2 = {
   'fname': file_name2,
   'fsize': round((file_stats [stat.ST_SIZE] / 1024) /1024.0, 2),
   'f_lm': time.strftime("%m/%d/%Y %I:%M:%S %p",time.localtime(file_stats[stat.ST_MTIME])),
   'f_la': time.strftime("%m/%d/%Y %I:%M:%S %p",time.localtime(file_stats[stat.ST_ATIME])),
   'f_ct': time.strftime("%m/%d/%Y %I:%M:%S %p",time.localtime(file_stats[stat.ST_CTIME]))

}

md52 = hashlib.md5(open(file_name2, 'rb').read()).hexdigest() 
sha2562 = hashlib.sha256(open(file_name2, 'rb').read()).hexdigest()

print "File Name     = %(fname)s" % file_info2
print "File Size     = %(fsize)s Megabytes" % file_info2
print "Last Modified = %(f_lm)s" % file_info2
print "Last Accessed = %(f_la)s" % file_info2
print "Creation Time = %(f_ct)s" % file_info2
print "MD5 Hash      = %s" % md52
print "SHA 256 Hash  = %s" % sha2562
print '\n'

if md5 == md52: 
    print colorred.format("The MD5 Hashes of the files are the same.")
    print "%s : %s  " % (file_name, md5)
    print "%s : %s  " % (file_name2, md52)
    print '\n'
else:
    print colorgrn.format("The MD5 Hashes are not the same.")
   


if sha256 == sha2562: 
    print colorred.format("The SHA256 Hashes of the files are the same.")
    print "%s : %s  " % (file_name, sha256)
    print "%s : %s  " % (file_name2, sha2562)
    print '\n'
else:
    print colorgrn.format("The SHA256 Hashes are not the same.")
    print '\n'
 
