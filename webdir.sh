#!/bin/bash

# Specify the input file containing IP addresses
input_file="ips1.txt"

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
