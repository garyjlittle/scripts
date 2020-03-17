#! /bin/bash

DEVICE=$1
SIZE=10g
RUNTIME=60
RNDREADRUNTIME=100
RUNID=$(date +'%y%m%d%H%M'-$$)

if [[ -z $DEVICE ]] ; then
  echo DEVICE is empty - we need a device name passed as first parameter
  exit 1
fi

MOUNT=$(df | grep /dev/$DEVICE | awk '{ print $6 }')

if [[ -z $MOUNT ]] ; then
  echo Could not find mount point for $DEVICE
  exit 1
fi

echo "Mountpoint for device $DEVICE is $MOUNT"

# Create a file to do IO upon
SEQIODEPTH=8
SEQIOSIZE=1m
let TARGETRNDIODEPTH=192
RNDIOSIZE=4k
DOSEQUENTIALWRITE=true
DOSEQUENTIALREAD=true
DORANDOMREAD=true
DORANDOMWRITE=true
DOONLYLATENCY=false

echo Target IO Depth for RANDOM = $TARGETRNDIODEPTH
let NUMDEVICES=6
let RNDIODEPTH=$TARGETRNDIODEPTH/$NUMDEVICES

echo Effective IO Dept per device file for RANDOM = $RNDIODEPTH



for filename in testfile testfile2 testfile3 testfile4 testfile5 testfile6 
do
if [[ -e $MOUNT/$filename ]] ; then
 /bin/true
else
 fio --name=prefill --filename=$MOUNT/$filename --bs=$SEQIOSIZE --size=$SIZE --rw=write --direct=1 --ioengine=libaio --iodepth=$SEQIODEPTH
fi
done

if [[ $DOONLYLATENCY != true ]] ; then

#Sequential Write
if [[ $DOSEQUENTIALWRITE = true ]] ; then
 echo Sequential Write QD=$SEQIODEPTH
 fio --name=seq_write --filename=$MOUNT/testfile --bs=$SEQIOSIZE --rw=write --time_based --runtime=$RUNTIME --direct=1 --ioengine=libaio --iodepth=$SEQIODEPTH --output=$RUNID-$DEVICE-seq-write.out
 echo
 sleep 5
fi

#Sequential Read
if [[ $DOSEQUENTIALREAD = true ]] ; then
 echo Sequential Read QD=$SEQIODEPTH
 fio --name=seq_read --filename=$MOUNT/testfile --bs=$SEQIOSIZE --rw=read --time_based --runtime=$RUNTIME --direct=1 --ioengine=libaio --iodepth=$SEQIODEPTH --output=$RUNID-$DEVICE-seq-read.out
 echo
 sleep 5
fi

#Random Read
if [[ $DORANDOMREAD = true ]] ; then
 echo Random Read QD=$TARGETRNDIODEPTH
 fio --name=global --group_reporting --bs=$RNDIOSIZE --rw=randread --time_based --runtime=$RUNTIME --direct=1 --ioengine=libaio --iodepth=$RNDIODEPTH --output=$RUNID-$DEVICE-rnd-read.out --name=read1 --filename=$MOUNT/testfile --name=read2 --filename=$MOUNT/testfile2 --name=read3 --filename=$MOUNT/testfile3 --name=read4 --filename=$MOUNT/testfile4 --name=read5 --filename=$MOUNT/testfile5 --name=read6 --filename=$MOUNT/testfile6
 echo
fi

#Random Write
if [[ $DORANDOMWRITE = true ]] ; then 
  echo Random Write QD-$TARGETRNDIODEPTH
  echo Per Device QD-$RNDIODEPTH
  fio --name=global --group_reporting --bs=$RNDIOSIZE --rw=randwrite --time_based --runtime=$RUNTIME --direct=1 --ioengine=libaio --iodepth=$RNDIODEPTH --output=$RUNID-$DEVICE-rnd-write.out --name=write1 --filename=$MOUNT/testfile --name=write2 --filename=$MOUNT/testfile2 --name=write3 --filename=$MOUNT/testfile3 --name=write4 --filename=$MOUNT/testfile4 --name=read5 --filename=$MOUNT/testfile5 --name=read6 --filename=$MOUNT/testfile6
  echo
fi

fi
#
# Repeat for single OIO
#
echo
echo "Single Outstanding IO for latency"
echo

#Random Write - Single OIO
RNDIODEPTH=1
if [[ $DORANDOMWRITE = true ]] ; then 
  echo Random Write QD-$RNDIODEPTH
  fio --name=global --group_reporting --bs=$RNDIOSIZE --rw=randwrite --time_based --runtime=$RUNTIME --direct=1 --ioengine=libaio --iodepth=$RNDIODEPTH --output=$RUNID-$DEVICE-QE-$RNDIODEPTH-rnd-write.out --name=write1 --filename=$MOUNT/testfile --name=write2 --filename=$MOUNT/testfile2
  echo
fi

#Random Read - Single OIO
RNDIODEPTH=1
if [[ $DORANDOMREAD = true ]] ; then
 echo Random Read QD=$RNDIODEPTH
 fio --name=global  --group_reporting --bs=$RNDIOSIZE --rw=randread --time_based --runtime=$RUNTIME --direct=1 --ioengine=libaio --iodepth=$RNDIODEPTH --output=$RUNID-$DEVICE-QD-$RNDIODEPTH-rnd-read.out --name=read1 --filename=$MOUNT/testfile --name=read2 --filename=$MOUNT/testfile2
 echo
fi

