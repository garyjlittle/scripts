# scripts
Public scripts

## checkdevice
Check to see if a device is mounted, part of a PV or has a partition table.  Give an indication if the raw device is safe to write to.
## measure_device
This can be used to give a quick summary of performance characteristics for a given device that has a filesystem mounted on it.  We use a filesystem (with directIO) so that we can measure write performance in a "brown field" environment e.g. one where a filesystem is already in existence.

### usage
```
./measure_device.sh sdb
./measure_device.sh nvme1n1p1
```
