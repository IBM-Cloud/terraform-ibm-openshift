#!/bin/sh
echo "Executing script $2 on root@$1"
ssh root@$1 'bash -s' < $2
echo "done"
