#!/bin/bash

strace -f -o /tmp/config.log ./configure

FILES=$(grep open /tmp/config.log | \
       perl -pe 's!.* open\(\"([^\"]*).*!$1!' | \
       grep "^/"| sort | uniq | \
       grep -v "^\(/tmp\|/dev\|/proc\)")


for x in `dpkg -S $FILES 2>/dev/null | cut -f1 -d":" | sort | uniq`
do
    echo -n "$x (>=" `dpkg -s $x|grep ^Version|cut -f2 -d":"` "), "
done

rm -f /tmp/config.log
