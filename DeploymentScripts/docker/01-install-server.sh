#!/bin/bash

function write_script() {
	echo "#!/bin/bash" > "$1"
	echo "$2 \$@" >> "$1"
	chmod +x "$1"
}

function create_folder_if_not_exists() {
    local folder_path="$1"
    
    # Check if the folder exists
    if [ ! -d "$folder_path" ]; then
        # If it doesn't exist, create it
        mkdir -p "$folder_path"
        echo "Folder created: $folder_path" >> /nanolock/log.log 2>&1
    else
        echo "Folder already exists: $folder_path" >> /nanolock/log.log 2>&1
    fi
}

function write_nanolock_services_script() {
	echo "#!/bin/bash" > "$1"
	echo 'if [ -f "${NANOLOCK_HOME}/deployment-scripts/.env" ]; then' >> "$1"
	echo "	export \$(sed -r 's/^\s*(.*\S)*\s*\$/\1/;/^\$/d' \${NANOLOCK_HOME}/deployment-scripts/.env | xargs)" >> "$1"
	echo 'fi' >> "$1"
	echo "docker-compose -f \$NANOLOCK_HOME/deployment-scripts/docker-compose.yml \$@" >> "$1"
	chmod +x "$1"
}

function write_nanolock_dockers_script() {
	echo "#!/bin/bash" > "$1"
	echo 'if [ -f "${NANOLOCK_HOME}/deployment-scripts/.env" ]; then' >> "$1"
	echo "	export \$(sed -r 's/^\s*(.*\S)*\s*\$/\1/;/^\$/d' \${NANOLOCK_HOME}/deployment-scripts/.env | xargs)" >> "$1"
	echo 'fi' >> "$1"
	echo "docker-compose -f \$NANOLOCK_HOME/deployment-scripts/docker-compose-infra.yml -f \$NANOLOCK_HOME/deployment-scripts/docker-compose.yml  \$@" >> "$1"
	chmod +x "$1"
}

function write_nanolock_stats_script() {
	echo "#!/bin/bash" > "$1"
	echo 'COLUMN=${1:-2}' >> "$1"
	echo 'watch "docker stats --format \"table {{.Name}}\t{{.CPUPerc}}\t{{.MemPerc}}\" --no-stream | sort -rnk ${COLUMN}"' >> "$1"
}

# Function to validate the password
validate_password() {
  password="$1"
  
  # Check if the password has at least 8 characters
  if [ ${#password} -lt 8 ]; then
    return 1
  fi

  # Check if the password contains at least one special character from the allowed list
  if ! [[ "$password" =~ [#+*?!^] ]]; then
    return 1
  fi

  return 0
}

# Function to validate the password
validate_password_ft() {
  password="$1"
  
  # Check if the password has at least 8 characters
  if [ ${#password} -lt 8 ]; then
    return 1
  fi

  # Check if the password contains at least one special character from the allowed list
  if ! [[ "$password" =~ [#+*?!%$^] ]]; then
    return 1
  fi

  return 0
}

# Function to read a validated password
read_validated_password() {
  prompt="$1"
  validate_password="$2"
  while true; do
    read -s -p "$prompt: " password
    echo
    read -s -p "Confirm $prompt: " password_confirm
    echo
    if [ "$password" == "$password_confirm" ]; then
      if $validate_password "$password"; then
        break
      else
        echo "Password must have at least 8 characters and at least one special character. Please try again."
      fi
    else
      echo "Passwords do not match. Please try again."
    fi
  done
}

function install_aws_cli() {
	pip3 install requests
	pip3 install boto3
	pip3 install awscli
	pip3 install --user requests
	pip3 install --user boto3
	pip3 install --user awscli
	if [[ -f aws-config.env ]] ; then
		echo "Automatically configuring AWS CLI."
		export $(cat aws-config.env | xargs)
		mkdir /root/.aws || (echo "Failed to create AWS folder" && exit 1)	
		echo "[default]" >> /root/.aws/credentials
		echo "AWS_ACCESS_KEY_ID = $AWS_ACCESS_KEY_ID" >> /root/.aws/credentials
		echo "AWS_SECRET_ACCESS_KEY = $AWS_SECRET_ACCESS_KEY" >> /root/.aws/credentials
		
		if [[ "$AWS_DEFAULT_OUTPUT" -eq "" ]] ; then
			export AWS_DEFAULT_OUTPUT=json
		fi
		
		if [[ "$AWS_DEFAULT_REGION" -eq "" ]] ; then
			export AWS_DEFAULT_REGION=eu-central-1
		fi
		
		echo "[default]"  >> /root/.aws/config
		echo "output = $AWS_DEFAULT_OUTPUT" >> /root/.aws/config
		echo "region = $AWS_DEFAULT_REGION" >> /root/.aws/config
		
		cp -R /root/.aws /tmp/"$USER_NAME"/ || { echo "command failed"; exit 1; }
		chown -R "$USER_NAME" /tmp/"$USER_NAME"/.aws || { echo "command failed"; exit 1; }	
	else
		aws configure
	fi
}

#Remove all cron jobs for the current user
if [ -z "$(crontab -l 2>/dev/null)" ]; then
    crontab -r
else
    echo "Crontab contains tasks, skipping removal."
fi

USER_NAME=$(logname)
echo 'NANOLOCK_HOME=/nanolock' >> /etc/environment 
echo "INSTALL_DIR=/tmp" | sudo tee -a /etc/environment 
echo 'nanop=NanoLockSec!' >> /etc/environment 
echo "USER_NAME=$USER_NAME" | sudo tee -a /etc/environment 
source /etc/environment
if [ -d "/tmp/utilities" ]; then
    # Call validate_files.sh
    ./validate_files.sh

    # Check the exit status of validate_files.sh
    if [ $? -ne 0 ]; then
        echo "File validation failed: there are missing files in 'utilities' or 'images-otd'. Exiting."
    fi

    echo "File validation succeeded. Continuing with installation."
    echo "Installing dependencies..."
    ./offline-preparation.sh
else
    # Check connectivity to 8.8.8.8
	if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
			echo "Network connectivity detected. Running online preparation..."
			./online-preparation.sh
	else
		echo "Network connectivity not detected. Exiting."
	fi

fi

chmod +x /usr/local/bin/docker-compose || { echo "command failed"; exit 1; }

create_folder_if_not_exists /nanolock
create_folder_if_not_exists /nanolock/postgres
create_folder_if_not_exists /nanolock/postgres/data
create_folder_if_not_exists /nanolock/assets
create_folder_if_not_exists /nanolock/assets/files
create_folder_if_not_exists /nanolock/elasticsearch
create_folder_if_not_exists /nanolock/elasticsearch/logs
create_folder_if_not_exists /nanolock/elasticsearch/data
create_folder_if_not_exists /nanolock/logstash
create_folder_if_not_exists /nanolock/kibana
create_folder_if_not_exists /nanolock/vault
create_folder_if_not_exists /nanolock/vault/config
create_folder_if_not_exists /nanolock/netdata
create_folder_if_not_exists /nanolock/netdata/plugins
create_folder_if_not_exists /nanolock/netdata/logs
create_folder_if_not_exists /nanolock/netdata/plugins/python
create_folder_if_not_exists /var/log/nanolock

chown -R "$USER_NAME" /nanolock/vault/config
chmod -R 755 /nanolock/vault/config

echo Chaning owner to: "$USER_NAME" >> /nanolock/log.log 2>&1
chown -R "$USER_NAME" /nanolock || { echo "command failed"; exit 1; }
chown -R "$USER_NAME" /var/log/nanolock || { echo "command failed"; exit 1; }
chmod 777 /var/log/nanolock || { echo "command failed"; exit 1; }
echo 'COMPOSE_IGNORE_ORPHANS=True' >> /etc/environment 
echo 'LD_LIBRARY_PATH=/usr/local/lib' >> /etc/environment 
write_nanolock_dockers_script "/usr/local/bin/nanolock-dockers" 
write_nanolock_services_script "/usr/local/bin/nanolock-services" 
write_nanolock_stats_script "/usr/local/bin/nanolock-stats" 
write_script "/usr/local/bin/nanolock-infra" "docker-compose -f \$NANOLOCK_HOME/deployment-scripts/docker-compose-infra.yml"
# write_script "/usr/local/bin/nanolock-migrate" "docker-compose -f \$NANOLOCK_HOME/deployment-scripts/docker-compose-migrate.yml"
write_script "/usr/local/bin/nanolock-watch" "watch 'docker ps -a --format \"table {{.Names}}\\t{{.Status}}\"'"
echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
echo 'net.ipv4.icmp_echo_ignore_all=1' >> /etc/sysctl.conf
echo 'net.core.netdev_budget=2400' >> /etc/sysctl.conf
echo 'net.core.netdev_budget_usecs=20000' >> /etc/sysctl.conf
#apt install -y python3-pip

if [ -f "/swapfile" ] ; then
	echo "Swap is already enable"
else
	while true; do
		read -p "Do you wish to enable swap? " yn
		case $yn in
		[Yy]* )	./enable-swap.sh; break;;
		[Nn]* ) break;;
			* ) echo "Please answer yes or no.";;
		esac
	done
fi

while true; do
    read -p "Are you installing a standalone server? " yn
    case $yn in
	[Yy]* )	./setup-slave.sh "y"; break;;
	[Nn]* ) ./setup-slave.sh "n"; break;;
        * ) echo "Please answer yes or no.";;
    esac
done

./configure-ip-dns.sh ssl;

./defender-type.sh 3;

while true; do
    read -p "Do you wish to modify support details? " yn
    case $yn in
	[Yy]* )	./support.sh "y"; break;;
	[Nn]* ) break;;
        		* ) echo "Please answer yes or no.";;
	esac
done


while true; do
    read -p "Do you wish to have a single password for all the services? " yn
    case $yn in
        [Yy]* )    
            # Read and validate the password
            read_validated_password "Enter your password for all the services" "validate_password"
            # Use the validated password variable in your script
            # ./update-pw.sh KEYCLOAK $password
            ./update-pw.sh POSTGRES $password
            ./update-pw.sh MoTAdmin $password
			#./update-pw.sh factorytalkprog $password
			#./update-pw.sh factorytalksuper $password
            break;;
        [Nn]* )    

            # Read and validate the password
            read_validated_password "Enter your password for postgres service" "validate_password"
            # Use the validated password variable in your script
            #echo "Password is set to: $password"
            ./update-pw.sh POSTGRES $password

            # Read and validate the password
            read_validated_password "Enter your password for MoTAdmin user" "validate_password"
            # Use the validated password variable in your script
            #echo "Password is set to: $password"
            ./update-pw.sh MoTAdmin $password

            break;;
        * ) 
            echo "Please answer yes or no."
            ;;
    esac
done


while true; do
    read -p "Enable FactoryTalk support? " yn
    case $yn in
	[Yy]* )	
		while true; do
			read -p "Do you wish to have a single password to superuser & programmer? " yn
			case $yn in
				[Yy]* )    
					# Read and validate the password
					read_validated_password "Enter your password for all the services" "validate_password_ft"
					# Use the validated password variable in your script
					./update-pw.sh factorytalksuper $password
					./update-pw.sh factorytalkprog $password
					break;;
				[Nn]* )    
					# Read and validate the password
					read_validated_password "Enter your password for factorytalkprog user" "validate_password_ft"
					# Use the validated password variable in your script
					#echo "Password is set to: $password"
					./update-pw.sh factorytalkprog $password

					# Read and validate the password
					read_validated_password "Enter your password for factorytalksuper user" "validate_password_ft"
					# Use the validated password variable in your script
					#echo "Password is set to: $password"
					./update-pw.sh factorytalksuper $password
					break;;
				* ) 
					echo "Please answer yes or no."
					;;
			esac
		done
	break;;
	[Nn]* ) break;;
        		* ) echo "Please answer yes or no.";;
	esac
done

sudo -E ./02-install-server.sh $USER_NAME
 

sudo ./03-install-server.sh