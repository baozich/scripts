#!/bin/bash
#
# This script is relevant to Xen ARMv7 with Virtualization Extensions development.
# In order to make your Dom0 boot sequence faster on Versatile Express, you might
# want to consider passing init=/bin/bash to your kernel and then manually
# executing this minimal init script.
#

mount /proc
mount -t xenfs xenfs /proc/xen
mknod /dev/xen/evntchn c 10 61
mknod /dev/xen/privcmd c 10 59
mknod /dev/xen/gntdev c 10 60
mknod /dev/xen/xenbus_backend c 10 62
mknod /dev/xen/xenbus c 10 63
mknod -m660 /dev/loop0 b 7 0
mount -t sysfs sysfs /sys
mkdir -p /dev/pts
mount -t devpts devpts /dev/pts

export LD_LIBRARY_PATH=/usr/local/lib

echo "Starting Xenstored"
xenstored -T /root/xenstored.log &> /root/xenstored.out
echo "Xenstored started"

echo "Starting xenconsoled"
xenconsoled -i &
echo "Xenconsoled started"

echo "Setting up loop0"
losetup /dev/loop0 /root/guestfs
losetup -a

echo "Writing dom0 name to xenstore"
/usr/bin/xenstore-write "/local/domain/0/name" "Domain-0"
echo "Done"
