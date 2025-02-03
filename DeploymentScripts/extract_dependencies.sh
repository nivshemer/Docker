#!/bin/bash
installed_packages=$(dpkg-query -f '${Package}\n' -W)

# Create the directory to store the dependencies
mkdir -p /home/ubuntu/dependencies

# Change directory to /home/ubuntu/dependencies
cd /home/ubuntu/dependencies || exit

# Get a list of installed packages and save their dependencies
installed_packages=$(dpkg --get-selections | awk '{print $1}')
for package in $installed_packages; do
    apt-get download "$package"
done

echo "All installed dependencies downloaded and saved to /home/ubuntu/dependencies"
