#!/bin/bash

MASTER_IP="MASTER_IP_ADDRESS"
SWITCH_SCRIPT="/Nivshemer/switch-master-slave.sh"
SWITCH_ARG="SlaveToMaster"

# Check if the master server is alive over a 5-minute interval
for i in {1..2}; do
  if nc -zv -w 1 $MASTER_IP 5432 &> /dev/null; then
    # Master server is alive, exit the script
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Main server is alive, exit the script. server ip: $MASTER_IP" >> "/Nivshemer/log.log"
    exit 0
  fi
  # Log the message with timestamp
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Wait for 1 minute before the next check for ip: $MASTER_IP" >> "/Nivshemer/log.log"
  sleep 60
done


# If the loop completes, the master server is not alive
# Execute the switch script on the slave server
echo "$(date '+%Y-%m-%d %H:%M:%S') - Execute the switch script on the slave server for ip: $MASTER_IP" >> "/Nivshemer/log.log"
$SWITCH_SCRIPT $SWITCH_ARG
