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

# Prompt the user to select a network interface
read -p "Enter the network interface you want to get the IP address from: " selected_interface

# Check if the selected interface is valid
if [[ ! " ${interfaces[@]} " =~ " ${selected_interface} " ]]; then
    echo "Invalid network interface. Exiting."
    exit 1
fi

# Get and display the IP address of the selected interface
ip_address=$(ip -4 addr show "$selected_interface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
echo "IP Address of $selected_interface: $ip_address"

cd $folder_name

echo "Running Recon..."
#Recon
nmap -sC -sV -A $ip_address/24 | cat > nmap_scan.txt

