#!/bin/sh
echo "Copying file $1 to root@$2:$3"
scp $1 root@$2:$3
echo "done"
