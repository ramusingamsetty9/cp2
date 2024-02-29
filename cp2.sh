#!/bin/bash

echo "The script started execution"

#deletion of existing folder
echo"Do you want to delete previous data?"
read -p "Do you want to continue? (yes/no): " answer

if [[ "$answer" =~ ^[Yy][Ee][Ss]$ ]]; then
    	rm -r RTA_*
elif [[ "$answer" =~ ^[Nn][Oo]$ ]]; then
    echo"please backup the files"
else
    echo "Invalid response. Please enter 'yes' or 'no'."
fi
#Creation of new  folder
folder_name="RTA_$(date +\%Y\%m\%d_\%H\%M\%S)"
mkdir "$folder_name"

#creation of new  folder
echo "Folder '$folder_name' created."



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
read -p "enter the CIDR range subnet: " cidr
nmap -sC -sV -A "$ip_address"/$cidr | cat > nmap_scan.txt
echo "network data stored to nmap_scan.txt"
#critical ports open
nmap -sC -sV -T4 -open -Pn -p 21,22,3306,3389,445,143 192.168.1.0/24 "$ip_address"/$cidr | cat > critical.txt

arp-scan --localnet --interface=$iface | cat > devices.txt

echo "attack surface analysed and stored to devices.txt" 

#web service identification
echo "web servers are being analysed"
nmap --open -p 80 192.168.1.1/24 |grep -E -o "([0-9]{1,3}\.){3}[0-9]{1,3}"| awk '!seen[$0]++' | cat > web.txt 

#web security testing
nuclei -l web.txt -t http/ | cat > web_security_report.txt
echo "All Web app scans completed."

#Web directory testing
mkdir web_dir
cd web_dir
