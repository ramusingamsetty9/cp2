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
folder_name="RTA_$(date +\%d\%m\%Y_\%H\%M\%S)"
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
nmap --open -p 80 "$ip_address"/$cidr | grep -E -o "([0-9]{1,3}\.){3}[0-9]{1,3}" | awk '!seen[$0]++' | cat > web_ip.txt

#web security testing
# Specify the input file containing IP addresses
input_file="web_ip.txt"

# Specify the output directory
output_directory="nuclei_scans"

# Create the output directory if it doesn't exist
mkdir -p "$output_directory"

# Run Nuclei scan for each URL in the input file
while IFS= read -r url || [[ -n "$url" ]]; do
    output_file="$output_directory/${url//[:\/]/_}_nuclei_report.txt"
    nuclei -u "$url" -o "$output_file"
    echo "Nuclei scan for $url completed. Report saved in '$output_file'."
done < "$input_file"

echo "All Nuclei scans completed. Reports saved in the '$output_directory' directory."


#DIR_ENUM
# Specify the input file containing IP addresses
input_file="web_ip.txt"

# Specify the output directory
output_directory="dirb_reports"

# Create the output directory if it doesn't exist
mkdir -p "$output_directory"
# Run dirb scan for each IP address in the input file
while IFS= read -r ip || [[ -n "$ip" ]]; do
    output_file="$output_directory/${ip}_web_dir.txt"
    dirb "http://$ip" -o "$output_file"
    echo "Dirb scan for $ip completed. Report saved in '$output_file'."
done < "$input_file"

echo "All dirb scans completed. Reports saved in the '$output_directory' directory."

#Service Detection

