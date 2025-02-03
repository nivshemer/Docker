#!/bin/bash

# Function to create a folder if it doesn't exist
create_folder_if_not_exists() {
    local folder_path="$1"
    if [ ! -d "$folder_path" ]; then
        mkdir -p "$folder_path"
        echo "Folder created: $folder_path" >> /Nivshemer/log.log 2>&1
    fi
}

# Wait for Docker service to start
until service docker status | grep -q running; do
    echo "Waiting for Docker service..."
    sleep 1
done

echo "Docker service is running"
echo "Nivshemer home: $Nivshemer_HOME" >> /Nivshemer/log.log 2>&1

# Add user to the Docker group
echo "Adding user $1 to Docker group."
usermod -aG docker "$1"

# Extract and copy necessary files
unzip -b -o /tmp/Nivshemer_services.zip -d "$Nivshemer_HOME"
sudo cp -r /tmp/{deployment-scripts,service-configurations,nginx,postgres,grafana} "$Nivshemer_HOME"
sudo cp /tmp/{replication-setup.sh,02-install-server.sh,01-install-server.sh,replicaState.sh,init-secrets.sh,check_master_alive.sh,switch-master-slave.sh} "$Nivshemer_HOME"
sudo cp /tmp/support/help.component.html "$Nivshemer_HOME/support"

# Create required directories
create_folder_if_not_exists "$Nivshemer_HOME/postgres/archivedir"
create_folder_if_not_exists "$Nivshemer_HOME/grafana/plugins"
create_folder_if_not_exists "$Nivshemer_HOME/grafana/data"
create_folder_if_not_exists "$Nivshemer_HOME/prometheus"
create_folder_if_not_exists "$Nivshemer_HOME/prometheus/data"
create_folder_if_not_exists "$Nivshemer_HOME/assets/failsafe"
create_folder_if_not_exists "$Nivshemer_HOME/rabbit-mq/logs"

# Set ownership and permissions
chown -R "$1" "$Nivshemer_HOME"
chmod 777 "$Nivshemer_HOME/rabbit-mq/logs"
sudo chown -R "$1:$1" "$Nivshemer_HOME"/{grafana,prometheus,assets/failsafe}
chmod -R 777 "$Nivshemer_HOME"/{vault,grafana,prometheus,assets/failsafe}

# Start Vault container
docker-compose -f "$Nivshemer_HOME/deployment-scripts/docker-compose-vault.yml" up -d || {
    echo "Failed to start docker-compose-vault.yml" && exit 1
}

# Wait for Vault container to become healthy
CONTAINER_NAME="vault"
TIMEOUT=15
LOG_FILE="/Nivshemer/log.log"
SECONDS_WAITED=0

while [ $SECONDS_WAITED -lt $TIMEOUT ]; do
    HEALTH_STATUS=$(docker inspect --format='{{.State.Health.Status}}' "$CONTAINER_NAME" 2>/dev/null)

    if [ "$HEALTH_STATUS" == "healthy" ]; then
        echo "Vault container is healthy!" >> "$LOG_FILE" 2>&1
        break
    fi

    echo "Waiting for Vault container to become healthy: $((TIMEOUT - SECONDS_WAITED)) seconds left" >> "$LOG_FILE" 2>&1
    sleep 1
    SECONDS_WAITED=$((SECONDS_WAITED + 1))
done

[ "$SECONDS_WAITED" -eq "$TIMEOUT" ] && echo "Vault container did not become healthy in time." >> "$LOG_FILE" 2>&1

# Initialize secrets and environment variables
/tmp/init-secrets.sh
/tmp/populate_env.sh "$Nivshemer_HOME/postgres/.postgres.env" "secret/postgres/config"
sed -i 's/= /=/g' "$Nivshemer_HOME/postgres/.postgres.env"
/tmp/populate_env.sh "$Nivshemer_HOME/grafana/.grafana.env" "secret/grafana/config"

echo "DATA_SOURCE_NAME=postgresql://Nivshemersec:POSTGRES_PW@envvar.Nivshemersecurity.nl:5432?sslmode=disable" >> "$Nivshemer_HOME/grafana/.grafana.env"
grep -qxF "REPLICATION_USER=nano_replicator" "$Nivshemer_HOME/postgres/.postgres.env" || echo "REPLICATION_USER=nano_replicator" >> "$Nivshemer_HOME/postgres/.postgres.env"
grep -qxF "POSTGRES_USER=Nivshemersec" "$Nivshemer_HOME/postgres/.postgres.env" || echo "POSTGRES_USER=Nivshemersec" >> "$Nivshemer_HOME/postgres/.postgres.env"

# Configure NGINX certificates
chmod +x "$Nivshemer_HOME/nginx/"*.sh
"$Nivshemer_HOME/nginx/self_sign.sh" "domain"

# Start infrastructure services
docker-compose -f "$Nivshemer_HOME/deployment-scripts/docker-compose-infra.yml" up -d || {
    echo "Failed to start docker-compose-infra.yml" && exit 1
}

# Copy and remove PostgreSQL initialization files
docker cp "$Nivshemer_HOME/postgres/auditfailedlogin.sql" postgres:/etc/postgresql/auditfailedlogin.sql
docker cp "$Nivshemer_HOME/postgres/init.sql" postgres:/docker-entrypoint-initdb.d/init.sql
rm -rf "$Nivshemer_HOME/postgres/"{init.sql,auditfailedlogin.sql,replica_users.sh}

# Wait for RabbitMQ to be accessible
until wget -O - --spider http://localhost:15672 >> /Nivshemer/log.log 2>&1; do
    echo "Waiting for RabbitMQ..."
    sleep 1
done

# Configure RabbitMQ users and permissions
docker exec rabbit-mq rabbitmq-plugins enable --offline rabbitmq_mqtt
docker exec rabbit-mq rabbitmqctl add_user Nivshemersec Nivshemersec
docker exec rabbit-mq rabbitmqctl set_user_tags Nivshemersec administrator management
docker exec rabbit-mq rabbitmqctl set_permissions -p / Nivshemersec ".*" ".*" ".*"
docker exec rabbit-mq rabbitmqctl add_user device "O5rk#2M&Es59Av"
docker exec rabbit-mq rabbitmqctl set_permissions -p / device "^mqtt-subscription-device-.*" "^(amq\\.topic)|(mqtt-subscription-device-.*)$" "^(amq\\.topic)|(mqtt-subscription-device-.*)$"

# Configure Docker logging
echo '{"log-driver":"json-file","log-opts":{"max-size":"10m","max-file":"7"}}' > /etc/docker/daemon.json
