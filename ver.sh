#!/bin/bash

input_file="nmap_scan.txt"
output_file="service_versions.txt"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: $input_file not found."
    exit 1
fi

# Extract service names and versions from open and filtered ports, and write to the output file
grep -E "^[0-9]+/(open|filtered)" "$input_file" | awk '{gsub(/\/.*/, "", $2); print $2 " " $3}' | sort -u > "$output_file"

echo "Service names and versions extracted and saved to $output_file."
