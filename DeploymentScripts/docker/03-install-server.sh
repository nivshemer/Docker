#!/bin/bash

# Function to start Nivshemer services
start_Nivshemer_services() {
  local compose_file="${Nivshemer_HOME}/deployment-scripts/docker-compose.yml"

  if [[ -f "$compose_file" ]]; then
    echo "Starting Nivshemer services..."
    docker-compose -f "$compose_file" up -d || {
      print_error "Failed to start Nivshemer services."
      exit 1
    }
  else
    print_error "Docker Compose file not found: $compose_file"
    exit 1
  fi
}


is_slave=0
cd $Nivshemer_HOME
chmod +x *.sh
chmod +x $Nivshemer_HOME/postgres/*.sh
chmod +x $Nivshemer_HOME/kibana/healthcheck.sh
cd $Nivshemer_HOME/deployment-scripts/
chmod +x *.sh
echo "*****Adding new jobs to crontab*****" >> $Nivshemer_HOME/log.log 2>&1
(crontab -l 2>/dev/null; echo "*/5 * * * * $Nivshemer_HOME/collectContainersMetrics.sh") | crontab -
(crontab -l 2>/dev/null; echo "*/5 * * * * $Nivshemer_HOME/replicaState.sh") | crontab -
#(crontab -l 2>/dev/null; echo "0 23 * * * $Nivshemer_HOME/ft1_daily_snapshot.sh") | crontab -
service cron restart
#sudo service cron status
chmod +x $Nivshemer_HOME/kibana/healthcheck.sh

export PGPASSWORD=POSTGRES_PW
# Variables
PG_USER="Nivshemersec"
PG_HOST="127.0.0.1"
PG_PORT="5432"
LOG_FILE="$Nivshemer_HOME/log.log"

# Databases to create
DATABASES=("notifications" "groupsandpolicies" "assets" "devicekeystore")

# Create databases
for DB in "${DATABASES[@]}"; do
  sudo docker exec -e PGPASSWORD="$PGPASSWORD" -it postgres psql \
    -U "$PG_USER" -d postgres -h "$PG_HOST" -p "$PG_PORT" \
    -c "CREATE DATABASE $DB WITH ENCODING 'UTF8';" >> "$LOG_FILE" 2>&1

  if [ $? -ne 0 ]; then
    echo "Error creating database $DB" >> "$LOG_FILE"
  fi
done

# Create replication user
sudo docker exec -e PGPASSWORD="$PGPASSWORD" -it postgres psql \
  -U "$PG_USER" -d postgres -h "$PG_HOST" -p "$PG_PORT" \
  -c "CREATE USER nano_replicator WITH REPLICATION LOGIN ENCRYPTED PASSWORD '$PGPASSWORD';" >> "$LOG_FILE" 2>&1

if [ $? -ne 0 ]; then
  echo "Error creating replication user nano_replicator" >> "$LOG_FILE"
fi

cd $Nivshemer_HOME/deployment-scripts/
chmod +x *.sh
sudo ./migration.sh >> $Nivshemer_HOME/log.log 2>&1 || { echo "migration.sh command failed"; exit 1; }
start_Nivshemer_services

docker exec -it rabbit-mq rabbitmqctl change_password guest Nivshemersec >> $Nivshemer_HOME/log.log 2>&1 || { echo "Changing password for 'guest' user in RabbitMQ failed"; exit 1; }

docker exec -it elasticsearch /bin/bash -c "elasticsearch-users useradd Nivshemersec -p NivshemerSec! -r superuser" >> $Nivshemer_HOME/log.log 2>&1 || { echo "Adding 'Nivshemersec' user to Elasticsearch failed"; exit 1; }

docker exec -it elasticsearch /bin/bash -c "elasticsearch-users useradd kibaNivshemersec -p kibaNivshemersec -r kibana_system" >> $Nivshemer_HOME/log.log 2>&1 || { echo "Adding 'kibaNivshemersec' user to Elasticsearch failed"; exit 1; }

cd $Nivshemer_HOME

chmod +x $Nivshemer_HOME/grafana/addViewUser.sh
$Nivshemer_HOME/grafana/addViewUser.sh >> $Nivshemer_HOME/log.log 2>&1

if [ "$is_slave" -eq 1 ]; then
    $Nivshemer_HOME/replication-setup.sh
fi

# Configuration
CONTAINER_NAME="otd-service"  # Replace with your Vault container name
TIMEOUT=15              # Maximum wait time in seconds
LOG_FILE="/Nivshemer/log.log"

# Function to check container health
check_health() {
  docker inspect --format='{{.State.Health.Status}}' "$CONTAINER_NAME" 2>/dev/null
}

# Countdown and health check loop
SECONDS_WAITED=0
while [ $SECONDS_WAITED -lt $TIMEOUT ]; do
  HEALTH_STATUS=$(check_health)

  if [ "$HEALTH_STATUS" == "healthy" ]; then
    echo "otd-service container is healthy!" >> "$LOG_FILE" 2>&1
    exit 0
  fi

  echo "Waiting for otd-service container to become healthy: $((TIMEOUT - SECONDS_WAITED)) seconds left" >> "$LOG_FILE" 2>&1
  sleep 1
  SECONDS_WAITED=$((SECONDS_WAITED + 1))
done

# If the script reaches here, the container did not become healthy within the timeout
echo "otd-service container did not become healthy within $TIMEOUT seconds." >> "$LOG_FILE" 2>&1

# Define the passwords for the FactoryTalk users
factorytalksuper_pw="supervisor_pwd"
factorytalkprog_pw="programmer_pwd"

# Export the variables 
export factorytalksuper_pw
export factorytalkprog_pw

# Stage 1
sudo docker exec -it otd-service touch AuthenticateUser.txt

sudo docker exec -it otd-service curl -X POST "http://localhost:8070/api/Auth/AuthenticateUser" -H "accept: */*" -H "Nl-Platform: MOT" -H "Content-Type: application/json" -d '{"userName":"admin","password":"AuthenticateUserPassword"}' -c AuthenticateUser.txt -b AuthenticateUser.txt >> $Nivshemer_HOME/log.log 2>&1 || { echo "AuthenticateUser failed"; exit 1; }
# Stage 2
sudo docker exec -it otd-service curl -b AuthenticateUser.txt -X POST "http://localhost:8070/api/ExternalDevices/CreateFactoryTalkUser?userName=NivshemerSup&password=$factorytalksuper_pw&role=2" -H "accept: */*" -H "Nl-Platform: MOT" -d "">> $Nivshemer_HOME/log.log 2>&1 || { echo "AuthenticateUser sup failed"; exit 1; }
# Stage 3
sudo docker exec -it otd-service curl -b AuthenticateUser.txt -X POST "http://localhost:8070/api/ExternalDevices/CreateFactoryTalkUser?userName=NivshemerProg&password=$factorytalkprog_pw&role=1" -H "accept: */*" -H "Nl-Platform: MOT" -d "" >> $Nivshemer_HOME/log.log 2>&1 || { echo "AuthenticateUser prog failed"; exit 1; }

# Supervisor
# Nk%Sup$9
# programmer
# Nk%Pro$9

openssl aes-256-cbc -a -salt -pbkdf2 -in /Nivshemer/deployment-scripts/.secrets.env -out /Nivshemer/stores/.sec_enc.env -pass pass:$nanop >> $Nivshemer_HOME/log.log 2>&1

openssl aes-256-cbc -a -salt -pbkdf2 -in /Nivshemer/postgres/.postgres.env -out /Nivshemer/stores/.pos_enc.env -pass pass:$nanop >> $Nivshemer_HOME/log.log 2>&1

openssl aes-256-cbc -a -salt -pbkdf2 -in /Nivshemer/grafana/.grafana.env -out /Nivshemer/stores/.gra_enc.env -pass pass:$nanop >> $Nivshemer_HOME/log.log 2>&1

if [ -d "$INSTALL_DIR" ]; then
    echo "Directory $INSTALL_DIR exists. Cleaning that directory." >> $Nivshemer_HOME/log.log 2>&1
    rm -rf $INSTALL_DIR/*
    rm -rf $Nivshemer_HOME/01-install-server.sh 
    rm -rf $Nivshemer_HOME/02-install-server.sh 
    rm -rf $Nivshemer_HOME/03-install-server.sh
    rm -rf $Nivshemer_HOME/enable-swap.sh
    rm -rf $Nivshemer_HOME/ft1_daily_snapshot.sh
    rm -rf $Nivshemer_HOME/defender-type.sh
    rm -rf $Nivshemer_HOME/mot-upgrade.sh
    rm -rf $Nivshemer_HOME/offline-preparation.sh
    rm -rf $Nivshemer_HOME/validate_files.sh
    rm -rf $Nivshemer_HOME/online-preparation.sh
    rm -rf $Nivshemer_HOME/populate_env.sh
    rm -rf $Nivshemer_HOME/update-pw.sh
    rm -rf $Nivshemer_HOME/install-google-cloud.sh
    rm -rf $Nivshemer_HOME/Nivshemer-server.json
    rm -rf $Nivshemer_HOME/configure-ip-dns.sh
    rm -rf $Nivshemer_HOME/support.sh
    rm -rf $Nivshemer_HOME/autoSnapshot.sh
    rm -rf $Nivshemer_HOME/keycloak/.keycloak.env
    rm -rf $Nivshemer_HOME/postgres/.postgres.env
    rm -rf $Nivshemer_HOME/grafana/.grafana.env
    rm -rf $Nivshemer_HOME/deployment-scripts/.secrets.env
    rm -rf $Nivshemer_HOME/init-secrets.sh
    rm -rf $Nivshemer_HOME/ft1-vm.service
    rm -rf $Nivshemer_HOME/grafana/addViewUser.sh
    rm -rf $Nivshemer_HOME/log*
else
    echo "Error: Directory /tmp does not exist."
fi

# Check if REPLICA_STATE is set to "standAlone"
if [ "$REPLICA_STATE" = "standAlone" ]; then
  # Delete all files under /tmp
  rm -rf $Nivshemer_HOME/replication-setup.sh
  rm -rf $Nivshemer_HOME/setup-slave.sh
  rm -rf $Nivshemer_HOME/switch-master-slave.sh
  rm -rf $Nivshemer_HOME/check_master_alive.sh
  rm -rf $Nivshemer_HOME/stores/*.enc
else
  echo "REPLICA_STATE is not set to 'standAlone'. No files were deleted."
fi

Nivshemer-watch 
currentscript="$0"

 # Function that is called when the script exits:
 function finish {
 echo "Securely shredding ${currentscript}"; shred -u ${currentscript};
 }