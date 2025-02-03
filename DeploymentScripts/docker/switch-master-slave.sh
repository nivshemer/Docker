#!/bin/bash

# Check if at least one argument is provided
if [ $# -lt 1 ]; then
  echo "Usage: $0 <section>"
  exit 1
fi

MASTER_IP="MASTER_IP_ADDRESS"
SLAVE_IP="SLAVE_IP_ADDRESS"
old_ip=$(eval hostname -I | cut -d' ' -f1)

# Access the first argument ($1) and use it to determine which section to run
case "$1" in
  "MasterToSlave")
    echo "Running MasterToSlave"
    sudo systemctl restart docker >> /Nivshemer/log.log 2>&1
    #read -p "Please insert your master ip? " master_ip
    sudo sed -i '/REPLICA_STATE=naster/d' /etc/environment
    echo 'REPLICA_STATE=slave' >> /etc/environment
    service cron restart
    cd /Nivshemer/deployment-scripts
    cp docker-compose-infra.yml docker-compose-infra-master.yml >> /Nivshemer/log.log 2>&1 
    mv docker-compose-infra-slave.yml docker-compose-infra.yml -f >> /Nivshemer/log.log 2>&1
    cd /Nivshemer/postgres
    cp postgres.conf postgres_master.conf 
    mv postgres_slave.conf postgres.conf
    openssl aes-256-cbc -d -a -pbkdf2 -in $Nivshemer_HOME/stores/.pos_enc.env -out $Nivshemer_HOME/postgres/.postgres.env -pass pass:$nanop >> $Nivshemer_HOME/log.log 2>&1 
    openssl aes-256-cbc -d -a -pbkdf2 -in $Nivshemer_HOME/stores/.gra_enc.env -out $Nivshemer_HOME/grafana/.grafana.env -pass pass:$nanop >> $Nivshemer_HOME/log.log 2>&1 
    /Nivshemer/replication-setup.sh
    docker-compose -f /Nivshemer/deployment-scripts/docker-compose-infra.yml up -d

    #rm -rfv  /Nivshemer/keycloak/.keycloak.env
    rm -rfv  /Nivshemer/postgres/.postgres.env
    rm -rfv  /Nivshemer/grafana/.grafana.env
    # # Specify the path to the Netplan YAML file
    # netplan_file="/etc/netplan/*.yaml"

    # # Use sed to replace the old IP address with the new one in the file
    # sudo sed -i "s/$old_ip/$SLAVE_IP/g" $netplan_file

    # # Print a message to confirm the change
    # echo "IP address $old_ip has been changed to $SLAVE_IP in $netplan_file"

    # sudo sed -i "s/$old_ip/$SLAVE_IP/g" /etc/hosts

    # # Apply the Netplan configuration
    # sudo netplan apply
    ;;
  "SlaveToMaster")
    echo "Running SlaveToMaster"
    sudo sed -i '/REPLICA_STATE=slave/d' /etc/environment
    echo 'REPLICA_STATE=master' >> /etc/environment
    service cron restart
    cd /Nivshemer/deployment-scripts
    cp docker-compose-infra.yml docker-compose-infra_slave.yml 
    mv _docker-compose-infra_master.yml docker-compose-infra.yml -f
    cd /Nivshemer/postgres
    cp postgres.conf postgres.conf_slave.yml 
    mv postgres_master.conf postgres.conf -f
    # cp pg_hba.conf pg_hba.conf_slave.yml 
    # mv pg_hba_master.conf pg_hba.conf -f
    openssl aes-256-cbc -d -a -pbkdf2 -in $Nivshemer_HOME/stores/.pos_enc.env -out $Nivshemer_HOME/postgres/.postgres.env -pass pass:$nanop >> $Nivshemer_HOME/log.log 2>&1
    openssl aes-256-cbc -d -a -pbkdf2 -in $Nivshemer_HOME/stores/.gra_enc.env -out $Nivshemer_HOME/grafana/.grafana.env -pass pass:$nanop >> $Nivshemer_HOME/log.log 2>&1
    docker-compose -f /Nivshemer/deployment-scripts/docker-compose-infra.yml up -d
    #rm -rfv  /Nivshemer/keycloak/.keycloak.env
    rm -rfv  /Nivshemer/postgres/.postgres.env
    rm -rfv  /Nivshemer/grafana/.grafana.env
    docker exec -u postgres postgres pg_ctl promote -D /var/lib/postgresql/data
    crontab -l | grep -v 'check_master_alive' | crontab -

    # Specify the path to the Netplan YAML file
    netplan_file="/etc/netplan/*.yaml"

    # Use sed to replace the old IP address with the new one in the file
    sudo sed -i "s/$old_ip/$MASTER_IP/g" $netplan_file

    # Print a message to confirm the change
    echo "IP address $old_ip has been changed to $MASTER_IP in $netplan_file"

    sudo sed -i "s/$old_ip/$MASTER_IP/g" /etc/hosts

    # Apply the Netplan configuration
    sudo netplan apply
    ;;

  *)
    echo "Invalid section argument. Available sections: MasterToSlave, SlaveToMaster"
    exit 1
    ;;
esac
