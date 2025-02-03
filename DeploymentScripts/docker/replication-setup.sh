#!/bin/bash

# Function to display a message when the timer is complete
function timer_complete {
  echo "PostgreSQL service is ready."
  # Add any additional actions you want to perform when the timer is complete
}
#chmod +x /nanolock/postgres/db_backup.sh
# Set the timer duration to 2 minutes and 5 seconds (125 seconds)
timer_duration=90

# Start the timer
echo "Waiting for PostgreSQL service to be ready..."
sleep $timer_duration

# Timer complete, call the function to display a message
timer_complete

# Function to handle errors
handle_error() {
    echo "An error occurred during the execution of the command."
    exit 1
}

# Trap errors and call the handle_error function
trap 'handle_error' ERR

# Function to execute the backup commands
execute_commands()
{
  docker exec -it postgres /bin/bash -c "rm -rf  /var/lib/postgresql/data/*" && docker exec -it postgres pg_basebackup -h master_ip_address -D /var/lib/postgresql/data -U nano_replicator -v -P -R -X stream
}



# Try to execute the commands up to 3 times
max_retries=8
retry_count=0
success=false

while [ $retry_count -lt $max_retries ]; do
  if execute_commands; then
    success=true
    break
  else
    retry_count=$((retry_count + 1))
    echo "Retrying... ($retry_count/$max_retries)"
    sleep 10 # Add a delay before retrying
  fi
done

if [ "$success" = true ]; then
  echo "Command executed successfully."
else
  handle_error
fi


# When your script is finished, exit with a call to the function, "finish":
trap finish EXIT

# Function that is called when the script exits:
currentscript="$0"
function finish {
    echo "Securely shredding ${currentscript}"
    shred -u ${currentscript}
}

