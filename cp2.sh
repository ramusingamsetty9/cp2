#!/bin/bash

echo "The script started execution"

#Creation of new  folder
folder_name="RTA_$(date +\%Y\%m\%d_\%H\%M\%S)"
mkdir "$folder_name"

#creation of new  folder
echo "Folder '$folder_name' created."

#deletion of existing folder
rm RTA_*
echo "The previous folder & Data are deleted..!"

#Gathering Ip address:
echo "Select the network interface"
interfaces=($(ls /sys/class/net/))
for iface in "${interfaces[@]}"; do
	echo "$iface"
done


#Recon
nmap -sC -sV -A 
