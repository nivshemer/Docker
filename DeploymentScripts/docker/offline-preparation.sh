#!/bin/bash

# Function to check if Docker service exists
check_docker() {
    if systemctl list-units --type=service | grep -q "docker.service"; then
        echo "Docker service already installed, no need to install Docker."
        return 0
    else
        return 1
    fi
}

log_path="/nanolock/log.log"

# Create the directory if it does not exist
mkdir -p "$(dirname "$log_path")"

# Create the file if it does not exist
touch "$log_path"

echo "debug: docker installation by dependencies" >> /nanolock/log.log 2>&1
dpkg --remove systemd-timesyncd >> /nanolock/log.log 2>&1
echo "debug: ubuntu packages installation" >> /nanolock/log.log 2>&1

if [ -e utilities/vault ]; then
	unzip utilities/vault/vault_1.9.0_linux_amd64.zip >> /nanolock/log.log 2>&1
	sudo mv vault /usr/local/bin/ >> /nanolock/log.log 2>&1 || { echo "mv vault failed"; exit 1; }

	#vault --version
else
    echo "File or directory does not exist." >> /nanolock/log.log 2>&1
fi

if check_docker; then
	echo "debug: deploy docker images" >> /nanolock/log.log 2>&1
	if [ -f images ]; then
		for file in images-otd/*
		do
			docker load -i "$file"
		done
	else
		echo "Directory images-otd does not exist." >> /nanolock/log.log 2>&1
	fi
else
	if [ -e utilities/utils ]; then
		for (( i=1; i <= 2; ++i ))
		do
			for file in utilities/utils/*.deb
			do
				dpkg -i "$file" >> /nanolock/log.log 2>&1
			done
		done
	else
		echo "File or directory does not exist." >> /nanolock/log.log 2>&1
	fi

	echo "debug: docker packages installation" >> /nanolock/log.log 2>&1

	if [ -e utilities/docker ]; then
		for (( i=1; i <= 2; ++i ))
		do
			for file in utilities/docker/*.deb
			do
				dpkg -i "$file" >> /nanolock/log.log 2>&1
			done
		done
		echo "debug: docker-compose installation" >> /nanolock/log.log 2>&1
		#mv utilities/docker/docker-compose-linux-x86_64 docker-compose
		sudo mv utilities/docker/docker-compose /usr/local/bin/ >> /nanolock/log.log 2>&1
		sudo mv utilities/docker/jq /usr/local/bin/ >> /nanolock/log.log 2>&1
		sudo chmod +x /usr/local/bin/docker-compose >> /nanolock/log.log 2>&1
		sudo chmod +x /usr/local/bin/jq >> /nanolock/log.log 2>&1
	else
		echo "File or directory does not exist." >> /nanolock/log.log 2>&1
	fi

	echo "debug: deploy docker images" >> /nanolock/log.log 2>&1

	if [ -e images-otd/otd-service.tar ]; then
		for file in images-otd/*
		do
			docker load -i "$file"
		done
	else
		echo "Directory images-otd does not exist." >> /nanolock/log.log 2>&1
	fi
fi







