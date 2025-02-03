#!/bin/bash

# Function to start NanoLock services
start_nanolock_services() {
  local compose_file="${NANOLOCK_HOME}/deployment-scripts/docker-compose.yml"

  if [[ -f "$compose_file" ]]; then
    echo "Starting NanoLock services..."
    docker-compose -f "$compose_file" up -d || {
      print_error "Failed to start NanoLock services."
      exit 1
    }
  else
    print_error "Docker Compose file not found: $compose_file"
    exit 1
  fi
}


is_slave=0
cd $NANOLOCK_HOME
chmod +x *.sh
chmod +x $NANOLOCK_HOME/postgres/*.sh
chmod +x $NANOLOCK_HOME/kibana/healthcheck.sh
cd $NANOLOCK_HOME/deployment-scripts/
chmod +x *.sh
echo "*****Adding new jobs to crontab*****" >> $NANOLOCK_HOME/log.log 2>&1
(crontab -l 2>/dev/null; echo "*/5 * * * * $NANOLOCK_HOME/collectContainersMetrics.sh") | crontab -
(crontab -l 2>/dev/null; echo "*/5 * * * * $NANOLOCK_HOME/replicaState.sh") | crontab -
#(crontab -l 2>/dev/null; echo "0 23 * * * $NANOLOCK_HOME/ft1_daily_snapshot.sh") | crontab -
service cron restart
#sudo service cron status
chmod +x $NANOLOCK_HOME/kibana/healthcheck.sh

export PGPASSWORD=POSTGRES_PW
# Variables
PG_USER="nanolocksec"
PG_HOST="127.0.0.1"
PG_PORT="5432"
LOG_FILE="$NANOLOCK_HOME/log.log"

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

cd $NANOLOCK_HOME/deployment-scripts/
chmod +x *.sh
sudo ./migration.sh >> $NANOLOCK_HOME/log.log 2>&1 || { echo "migration.sh command failed"; exit 1; }
start_nanolock_services

docker exec -it rabbit-mq rabbitmqctl change_password guest nanolocksec >> $NANOLOCK_HOME/log.log 2>&1 || { echo "Changing password for 'guest' user in RabbitMQ failed"; exit 1; }

docker exec -it elasticsearch /bin/bash -c "elasticsearch-users useradd nanolocksec -p NanoLockSec! -r superuser" >> $NANOLOCK_HOME/log.log 2>&1 || { echo "Adding 'nanolocksec' user to Elasticsearch failed"; exit 1; }

docker exec -it elasticsearch /bin/bash -c "elasticsearch-users useradd kibananolocksec -p kibananolocksec -r kibana_system" >> $NANOLOCK_HOME/log.log 2>&1 || { echo "Adding 'kibananolocksec' user to Elasticsearch failed"; exit 1; }

cd $NANOLOCK_HOME

chmod +x $NANOLOCK_HOME/grafana/addViewUser.sh
$NANOLOCK_HOME/grafana/addViewUser.sh >> $NANOLOCK_HOME/log.log 2>&1

if [ "$is_slave" -eq 1 ]; then
    $NANOLOCK_HOME/replication-setup.sh
fi

# Configuration
CONTAINER_NAME="otd-service"  # Replace with your Vault container name
TIMEOUT=15              # Maximum wait time in seconds
LOG_FILE="/nanolock/log.log"

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

sudo docker exec -it otd-service curl -X POST "http://localhost:8070/api/Auth/AuthenticateUser" -H "accept: */*" -H "Nl-Platform: MOT" -H "Content-Type: application/json" -d '{"userName":"admin","password":"AuthenticateUserPassword"}' -c AuthenticateUser.txt -b AuthenticateUser.txt >> $NANOLOCK_HOME/log.log 2>&1 || { echo "AuthenticateUser failed"; exit 1; }
# Stage 2
sudo docker exec -it otd-service curl -b AuthenticateUser.txt -X POST "http://localhost:8070/api/ExternalDevices/CreateFactoryTalkUser?userName=NanolockSup&password=$factorytalksuper_pw&role=2" -H "accept: */*" -H "Nl-Platform: MOT" -d "">> $NANOLOCK_HOME/log.log 2>&1 || { echo "AuthenticateUser sup failed"; exit 1; }
# Stage 3
sudo docker exec -it otd-service curl -b AuthenticateUser.txt -X POST "http://localhost:8070/api/ExternalDevices/CreateFactoryTalkUser?userName=NanolockProg&password=$factorytalkprog_pw&role=1" -H "accept: */*" -H "Nl-Platform: MOT" -d "" >> $NANOLOCK_HOME/log.log 2>&1 || { echo "AuthenticateUser prog failed"; exit 1; }

# Supervisor
# Nk%Sup$9
# programmer
# Nk%Pro$9

openssl aes-256-cbc -a -salt -pbkdf2 -in /nanolock/deployment-scripts/.secrets.env -out /nanolock/stores/.sec_enc.env -pass pass:$nanop >> $NANOLOCK_HOME/log.log 2>&1

openssl aes-256-cbc -a -salt -pbkdf2 -in /nanolock/postgres/.postgres.env -out /nanolock/stores/.pos_enc.env -pass pass:$nanop >> $NANOLOCK_HOME/log.log 2>&1

openssl aes-256-cbc -a -salt -pbkdf2 -in /nanolock/grafana/.grafana.env -out /nanolock/stores/.gra_enc.env -pass pass:$nanop >> $NANOLOCK_HOME/log.log 2>&1

if [ -d "$INSTALL_DIR" ]; then
    echo "Directory $INSTALL_DIR exists. Cleaning that directory." >> $NANOLOCK_HOME/log.log 2>&1
    rm -rf $INSTALL_DIR/*
    rm -rf $NANOLOCK_HOME/01-install-server.sh 
    rm -rf $NANOLOCK_HOME/02-install-server.sh 
    rm -rf $NANOLOCK_HOME/03-install-server.sh
    rm -rf $NANOLOCK_HOME/enable-swap.sh
    rm -rf $NANOLOCK_HOME/ft1_daily_snapshot.sh
    rm -rf $NANOLOCK_HOME/defender-type.sh
    rm -rf $NANOLOCK_HOME/mot-upgrade.sh
    rm -rf $NANOLOCK_HOME/offline-preparation.sh
    rm -rf $NANOLOCK_HOME/validate_files.sh
    rm -rf $NANOLOCK_HOME/online-preparation.sh
    rm -rf $NANOLOCK_HOME/populate_env.sh
    rm -rf $NANOLOCK_HOME/update-pw.sh
    rm -rf $NANOLOCK_HOME/install-google-cloud.sh
    rm -rf $NANOLOCK_HOME/nanolock-server.json
    rm -rf $NANOLOCK_HOME/configure-ip-dns.sh
    rm -rf $NANOLOCK_HOME/support.sh
    rm -rf $NANOLOCK_HOME/autoSnapshot.sh
    rm -rf $NANOLOCK_HOME/keycloak/.keycloak.env
    rm -rf $NANOLOCK_HOME/postgres/.postgres.env
    rm -rf $NANOLOCK_HOME/grafana/.grafana.env
    rm -rf $NANOLOCK_HOME/deployment-scripts/.secrets.env
    rm -rf $NANOLOCK_HOME/init-secrets.sh
    rm -rf $NANOLOCK_HOME/ft1-vm.service
    rm -rf $NANOLOCK_HOME/grafana/addViewUser.sh
    rm -rf $NANOLOCK_HOME/log*
else
    echo "Error: Directory /tmp does not exist."
fi

# Check if REPLICA_STATE is set to "standAlone"
if [ "$REPLICA_STATE" = "standAlone" ]; then
  # Delete all files under /tmp
  rm -rf $NANOLOCK_HOME/replication-setup.sh
  rm -rf $NANOLOCK_HOME/setup-slave.sh
  rm -rf $NANOLOCK_HOME/switch-master-slave.sh
  rm -rf $NANOLOCK_HOME/check_master_alive.sh
  rm -rf $NANOLOCK_HOME/stores/*.enc
else
  echo "REPLICA_STATE is not set to 'standAlone'. No files were deleted."
fi

nanolock-watch 
currentscript="$0"

 # Function that is called when the script exits:
 function finish {
 echo "Securely shredding ${currentscript}"; shred -u ${currentscript};
 }