#!/bin/sh
echo "Update the file $2 with bastion public ip $1"
sed -i  -- "s/<bastion_address>/$1/g" $2
echo "done"
