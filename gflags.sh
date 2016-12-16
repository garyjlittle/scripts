#!/bin/bash -x

# Check to see if this environment variable is set, otherwise
# take the IP addres from the CLI argument $1
if [[ $CVMIP ]] ; then
    IP=$CVMIP
else
    IP=$1
fi

#  Make sure we have an IP address set (from somewhere) before 
#  going any further.
if [[ -z $IP ]] ; then
    echo "Need an IP address as argument"
    exit
fi

##  Go and get the gflags file from the CVM
echo Sending to CVM IP $IP
wget -q -O - $IP:2009/h/gflags > /tmp/gflags.old
cp /tmp/gflags.old /tmp/gflags.edit
#  Edit one copy
vim /tmp/gflags.edit

# Get the changes between the current flag set, and the
# flags as edited in vim, also ensure both files exist before proceding
#
sdiff /tmp/gflags.old /tmp/gflags.edit  -s | awk '{ print $3 }' | cut -c 3-999 > /tmp/gflags.changed

# Now send the changed flag back to the CVM
for FLAG in `cat /tmp/gflags.changed`
do
    if [[ $FLAG ]] ; then
        wget -q -O - $IP:2009/h/gflags?$FLAG
    fi
done
#rm /tmp/gflags.old
#rm /tmp/gflags.edit

