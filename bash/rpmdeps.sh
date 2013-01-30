#!/bin/bash

strace -f -o /tmp/config.strace ./configure

FILES=$(grep open /tmp/config.strace | \
        perl -pe 's/.* open\(\"([^\"]*).*/$1/' | \
        grep "^/" | sort | uniq | \
        grep -v "^\(/tmp\|/dev\|/proc\)" 2>/dev/null | \
        cut -f1 -d":" | sort | uniq)

echo > /tmp/deps.files

for x in $FILES
do
    echo $x >> /tmp/deps.files
done

cat /tmp/deps.files | \
    xargs -n 1 rpm -qf --queryformat "%{NAME}-%{VERSION}\n" 2>/dev/null | \
    grep -v "not owned by any package" > /tmp/deps.list

sort /tmp/deps.list | uniq

rm -f /tmp/deps.files
rm -f /tmp/deps.list
rm -f /tmp/config.strace
