#!/bin/bash

read -p "Please insert the new ip address ? " new_ip
# Define the old and new IP addresses
old_ip=$(eval hostname -I | cut -d' ' -f1)

# Specify the path to the Netplan YAML file
netplan_file="/etc/netplan/*.yaml"

# Use sed to replace the old IP address with the new one in the file
sudo sed -i "s/$old_ip/$new_ip/g" $netplan_file

# Apply the Netplan configuration
sudo netplan apply

# Print a message to confirm the change
echo "IP address $old_ip has been changed to $new_ip in $netplan_file"

sudo sed -i "s/$old_ip/$new_ip/g" /etc/hosts
