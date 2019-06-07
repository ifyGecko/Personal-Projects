#!/bin/bash

#Collect all drive paths in a txt file
fdisk -l | grep /dev/sd.[^1-9] | cut -c 6-13 > /tmp/tmp.txt

#calculate how many drives are to be cloned
line_count=$(wc -l /tmp/tmp.txt | cut -c 1)

#initial part the command string
cmd_str="dd if=/dev/sda bs=32M"

#build the remainder of the command string
for (( i=2; i<=$line_count; i++ ))
do
	drive=$(sed -n ${i}p /tmp/tmp.txt)
	cmd_str="$cmd_str | dd of=$drive"
done

#execute the command string with bash
bash -c $cmd_str

#shutdown when done cloning
shutdown -h now
