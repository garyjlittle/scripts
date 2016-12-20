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
##  Remove old temp files first
touch /tmp/gflags.old && rm /tmp/gflags.old
touch /tmp/gflags.edit && rm /tmp/gflags.edit
touch /tmp/gflags.changed && rm /tmp/gflags.changed

##  Go and get the gflags file from the CVM set the timeout to 5 seconds
##  and retries to 1.  It should not take > 5 seconds to reach 2009 handler.
echo Connecting to CVM IP $IP
wget -t 1 -T 5 -q -O - $IP:2009/h/gflags > /tmp/gflags.old
if [[ $? -gt 0 ]] ; then
    echo "wget failed to connect to $IP"
    exit 1
fi
cp /tmp/gflags.old /tmp/gflags.edit
#  Edit one copy
vim /tmp/gflags.edit

# Get the changes between the current flag set, and the
# flags as edited in vim, also ensure both files exist before proceding
#
sdiff /tmp/gflags.old /tmp/gflags.edit -s | awk 'BEGIN { FS = "|" } ; { print $2 }'|awk '{ print $1 }'|cut -c 3-999 > /tmp/gflags.changed
# Now send the changed flag back to the CVM
for FLAG in `cat /tmp/gflags.changed`
do
    if [[ $FLAG ]] ; then
        wget -q -O - $IP:2009/h/gflags?$FLAG
    fi
done

