#!/bin/sh

# load_netoops.sh脚本，放在被监控的机器上，脚本后跟的参数为：
# $1 syslog-ng机器的ip地址
# $2 syslog-ng机器的mac地址

NETOOPS_TARGET="/sys/kernel/config/netoops/target1"

if [ -d "$NETOOPS_TARGET" ]; then
	rmdir $NETOOPS_TARGET
fi

mkdir $NETOOPS_TARGET
pushd $NETOOPS_TARGET
echo `/sbin/ifconfig |grep "inet addr" |grep -v "127.0.0.1" |head -1|awk '{print $2}' |awk -F":" '{print $2}'` > local_ip
echo $1 > remote_ip
echo $2 > remote_mac
echo "520" > remote_port
echo "1" > enabled
popd
