#!/bin/bash
# Store the variables passed from the main script
REPLY=$1

if [ "$REPLY" == y ]
then

		echo 'REPLICA_STATE=standAlone' >> /etc/environment
			myip=$(eval hostname -I | cut -d' ' -f1)
            if [ -f "postgres/pg_hba.conf" ] ; then
                sed -i -e s/"SLAVE_IP_ADDRESS"/"$myip"/g "postgres/pg_hba.conf" || exit 1
            fi
            sed -i -e s/"master_ip_address"/"$myip"/g "replication-setup.sh" || exit 1

elif [ "$REPLY" == n ]
then

read -p "Are you installing the main server? " yn
read -p "What is your main IP address? " varmaster
read -p "What is your secondary IP address? " varslave

if [ $yn == y ]
        then
		echo 'REPLICA_STATE=master' >> /etc/environment
            if [ -f "postgres/pg_hba.conf" ] ; then
                sed -i -e s/"SLAVE_IP_ADDRESS"/"$varslave"/g "postgres/pg_hba.conf" || exit 1
				sed -i -e s/"MASTER_IP_ADDRESS"/"$varmaster"/g "postgres/pg_hba_slave.conf" || exit 1
            fi
				sed -i -e s/"master_ip_address"/"$varmaster"/g "replication-setup.sh" || exit 1
				sed -i -e s/"MASTER_IP_ADDRESS"/"$varmaster"/g "switch-master-slave.sh" || exit 1
				sed -i -e s/"SLAVE_IP_ADDRESS"/"$varslave"/g "switch-master-slave.sh" || exit 1
				sed -i -e s/"# Specify one or more NTP servers"/"server 127.127.1.0 prefer"/g /etc/ntp.conf
				sed -i -e s/"prefer."/"prefer"/g /etc/ntp.conf
				sed -i -e s/"pool ntp.ubuntu.com"/"#pool ntp.ubuntu.com"/g /etc/ntp.conf
				sed -i -e s/"pool 0.ubuntu.pool.ntp.org iburst"/"#pool 0.ubuntu.pool.ntp.org iburst"/g /etc/ntp.conf
				sed -i -e s/"pool 1.ubuntu.pool.ntp.org iburst"/"#pool 1.ubuntu.pool.ntp.org iburst"/g /etc/ntp.conf
				sed -i -e s/"pool 2.ubuntu.pool.ntp.org iburst"/"#pool 2.ubuntu.pool.ntp.org iburst"/g /etc/ntp.conf
				sed -i -e s/"pool 3.ubuntu.pool.ntp.org iburst"/"#pool 3.ubuntu.pool.ntp.org iburst"/g /etc/ntp.conf
				sudo sed -i '5i inet6 off' /etc/ntp.conf
				sudo sed -i '17i # Specify one or more NTP servers' /etc/ntp.conf
				sudo service ntp restart
				#ntpq -p
				date

elif [ $yn == n ]
        then
		read -p "Do you want to enable the automatic MoT handover for High-Availability? " yn
		if [ $yn == y ]
        then
		read -p "Automatic handover is enabled. Set interval(in mintues) to send a keep-alive message: " mintues 
		sed -i -e s/"MASTER_IP_ADDRESS"/"$varmaster"/g "postgres/pg_hba_slave.conf" || exit 1
		sed -i -e s/"MASTER_IP_ADDRESS"/"$varmaster"/g "check_master_alive.sh" || exit 1
		sed -i -e s/"MASTER_IP_ADDRESS"/"$varmaster"/g "switch-master-slave.sh" || exit 1
		sed -i -e s/"SLAVE_IP_ADDRESS"/"$varslave"/g "switch-master-slave.sh" || exit 1
		(crontab -l 2>/dev/null; echo "*/$mintues * * * * /nanolock/check_master_alive.sh") | crontab -
		service cron restart
		fi
		echo 'REPLICA_STATE=slave' >> /etc/environment
		sed -i -e s/"is_slave=0"/"is_slave=1"/g "03-install-server.sh" || exit 1
            if [ -f "deployment-scripts/docker-compose-infra.yml" ] ; then
                mv "deployment-scripts/docker-compose-infra.yml" "deployment-scripts/_docker-compose-infra_master.yml" 
				cp "deployment-scripts/docker-compose-infra-slave.yml" "deployment-scripts/docker-compose-infra_slave.yml" 
                mv "deployment-scripts/docker-compose-infra-slave.yml" "deployment-scripts/docker-compose-infra.yml" 
            fi
            if [ -f "postgres/postgres.conf" ] ; then
                mv "postgres/postgres.conf" "postgres/postgres_master.conf" 
                mv "postgres/postgres_slave.conf" "postgres/postgres.conf" 
                mv "postgres/pg_hba.conf" "postgres/pg_hba_master.conf" 
                mv "postgres/pg_hba_slave.conf" "postgres/pg_hba.conf" 
                sed -i -e s/"MASTER_IP_ADDRESS"/"$varmaster"/g "postgres/pg_hba.conf" || exit 1
                sed -i -e s/"MASTER_IP_ADDRESS"/"$varmaster"/g "check_master_alive.sh" || exit 1
            fi
				echo "Starting time zone synchronize with $varmaster"
				sed -i -e s/"master_ip_address"/"$varmaster"/g "replication-setup.sh" || exit 1
				sed -i -e s/"master_ip_address"/"$varmaster"/g "replication-setup.sh" || exit 1
				sed -i -e s/"# Specify one or more NTP servers"/"server $varmaster"/g /etc/ntp.conf
				sed -i -e s/"pool ntp.ubuntu.com"/"#pool $varmaster"/g /etc/ntp.conf
				sed -i -e s/"pool 0.ubuntu.pool.ntp.org iburst"/"#pool 0.ubuntu.pool.ntp.org iburst"/g /etc/ntp.conf
				sed -i -e s/"pool 1.ubuntu.pool.ntp.org iburst"/"#pool 1.ubuntu.pool.ntp.org iburst"/g /etc/ntp.conf
				sed -i -e s/"pool 2.ubuntu.pool.ntp.org iburst"/"#pool 2.ubuntu.pool.ntp.org iburst"/g /etc/ntp.conf
				sed -i -e s/"pool 3.ubuntu.pool.ntp.org iburst"/"#pool 3.ubuntu.pool.ntp.org iburst"/g /etc/ntp.conf
				sed -i -e s/"$varmaster."/"$varmaster"/g /etc/ntp.conf
				sudo sed -i '5i inet6 off' /etc/ntp.conf
				sudo sed -i '17i # Specify one or more NTP servers' /etc/ntp.conf
				sudo service ntp restart
				#ntpq -p
				date
        fi

fi
