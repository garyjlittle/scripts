#!/usr/bin/env -S bash 

if [ ! $(id -u) -eq 0 ] ; then echo "Must be root" ; exit 1; fi

DEV=$1
RET=0
echo Device is $DEV

#Check device exists
if [[ -b $DEV ]] ; then  echo "OK The device $DEV exists as a block device" ; else echo "No device found" ; exit 1 ; fi

#Check if the device has partitions
if sudo parted -s $DEV print >/dev/null 2>&1 ; then 
	echo "!! DANGER !! The device $DEV has a prtition table" 
	sudo parted -m -s $DEV print 
	RET=1 
else 
	echo "$DEV is free of partitions" 
fi

#Check to see if the partition is part of a PV
PV=0
for i in {1..10} ; do 
	if pvdisplay $DEV$i >/dev/null 2>&1 ; then 
		pvdisplay $DEV$i ; RET=1 ; PV=1
	fi	
done
if [[ $PV -eq 0 ]] ; then echo "OK Device $DEV is not part of a PV" ; fi 

#Check to see if device is mounted
if findmnt $DEV ; then echo "!! DANGER !! Device $DEV is mounted cannot use" ; RET=1 ; else echo "OK Device $DEV is not mounted" ; fi

#Return OK
if [[ $RET -gt 0 ]] ; then echo -e "\n\n!! DANGER !! Device $DEV may be in use\n\n" ; else echo -e "\n\nOK Device $DEV Looks OK to use\n\n" ; fi
exit $RET
