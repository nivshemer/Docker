#!/bin/bash
log_path="/nanolock/log.log"
# Create the directory if it does not exist
mkdir -p "$(dirname "$log_path")"

# Create the file if it does not exist
touch "$log_path"

apt install -y python3-pip
apt update || { echo "command failed"; exit 1; }
apt install -y \
	unzip \
	apt-transport-https \
	ca-certificates \
	curl \
	software-properties-common 
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -  > /nanolock/log 2>&1 || { exit 1; }
add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
	$(lsb_release -cs) \
	stable"  

apt update  #> /nanolock/log 2>&1 || { exit 1; }
apt install -y docker-ce  #> /nanolock/log 2>&1 || { exit 1; }
sudo apt-get install docker.io  #> /nanolock/log 2>&1 || { exit 1; }
systemctl status docker.io #> /nanolock/log 2>&1 || { exit 1; }
sudo systemctl daemon-reload #> /nanolock/log 2>&1 || { exit 1; }
sudo systemctl enable docker #> /nanolock/log 2>&1 || { exit 1; }
sudo systemctl start docker #> /nanolock/log 2>&1 || { exit 1; }
sudo apt-get update #> /nanolock/log 2>&1 || { exit 1; }
sudo apt-get install docker-ce docker-ce-cli containerd.io #> /nanolock/log 2>&1 || { exit 1; }

#systemctl status docker #> /nanolock/log 2>&1 || { exit 1; }

sudo curl -L "https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose 


wget https://releases.hashicorp.com/vault/1.10.4/vault_1.10.4_linux_amd64.zip
unzip vault_1.10.4_linux_amd64.zip
sudo mv vault /usr/local/bin/
#vault --version

wget -O jq https://github.com/stedolan/jq/releases/latest/download/jq-linux64
sudo mv /tmp/jq /usr/local/bin/
chmod +x /usr/local/bin/jq




./install-google-cloud.sh 