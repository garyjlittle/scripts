#! /bin/bash

DEVICE=$1
SIZE=10g
RUNTIME=30
RNDREADRUNTIME=100
RUNID=$(date +'%y%m%d%H%M'-$$)

if [[ -z $DEVICE ]] ; then
  echo DEVICE is empty - we need a device name passed as first parameter
  exit 1
fi

MOUNT=$(df | grep $DEVICE | awk '{ print $6 }')

if [[ -z $MOUNT ]] ; then
  echo Could not find mount point for $DEVICE
  exit 1
fi

echo "Mountpoint for device $DEVICE is $MOUNT"

# Create a file to do IO upon
SEQIODEPTH=8
SEQIOSIZE=1m
RNDIODEPTH=32
RNDIOSIZE=4k
DOSEQUENTIALWRITE=true
DOSEQUENTIALREAD=true
DORANDOMREAD=true
DORANDOMWRITE=true

for filename in testfile testfile2 testfile3 testfile4 testfile5 testfile6 testfile7 testfile8 testfile9 testfile10 testfile11 testfile12
do
if [[ -e $MOUNT/$filename ]] ; then
 /bin/true
else
 fio --name=prefill --filename=$MOUNT/$filename --bs=$SEQIOSIZE --size=$SIZE --rw=write --direct=1 --ioengine=libaio --iodepth=$SEQIODEPTH
fi
done

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
 echo Random Read QD=$RNDIODEPTH
 #fio --name=global --group_reporting --bs=$RNDIOSIZE --rw=randread --time_based --runtime=$RNDREADRUNTIME --direct=1 --ioengine=libaio --iodepth=$RNDIODEPTH --output=$RUNID-$DEVICE-rnd-read.out --name=read1 --filename=$MOUNT/testfile --name=read2 --filename=$MOUNT/testfile2 --name=read3 --filename=$MOUNT/testfile3 --name=read4 --filename=$MOUNT/testfile4 --name=read5 --filename=$MOUNT/testfile5 --name=read6 --filename=$MOUNT/testfile6 --name=read7 --filename=$MOUNT/testfile7 --name=read8 --filename=$MOUNT/testfile8 --name=read9 --filename=$MOUNT/testfile9 --name=read10 --filename=$MOUNT/testfile10 --name=read11 --filename=$MOUNT/testfile11 --name=read12 --filename=$MOUNT/testfile12
 fio --name=global --numjobs=1 --group_reporting --bs=$RNDIOSIZE --rw=randread --time_based --runtime=$RUNTIME --direct=1 --ioengine=libaio --iodepth=$RNDIODEPTH --output=$RUNID-$DEVICE-rnd-read.out --name=read1 --filename=$MOUNT/testfile --name=read2 --filename=$MOUNT/testfile2 --name=read3 --filename=$MOUNT/testfile3 --name=read4 --filename=$MOUNT/testfile4 --name=read5 --filename=$MOUNT/testfile5 --name=read6 --filename=$MOUNT/testfile6
 echo
fi

#Random Write
if [[ $DORANDOMWRITE = true ]] ; then 
  echo Random Write QD-$RNDIODEPTH
  #fio --name=rnd_write --filename=$MOUNT/testfile --bs=$RNDIOSIZE --rw=randwrite --time_based --runtime=$RUNTIME --direct=1 --ioengine=libaio --iodepth=$RNDIODEPTH --output=$RUNID-$DEVICE-rnd-write.out
  fio --name=global --group_reporting --bs=$RNDIOSIZE --rw=randwrite --time_based --runtime=$RUNTIME --direct=1 --ioengine=libaio --iodepth=$RNDIODEPTH --output=$RUNID-$DEVICE-rnd-write.out --name=write1 --filename=$MOUNT/testfile --name=write2 --filename=$MOUNT/testfile2 --name=write3 --filename=$MOUNT/testfile3 --name=write4 --filename=$MOUNT/testfile4
  echo
fi
