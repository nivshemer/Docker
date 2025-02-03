#!/bin/bash

function reportReplicationStatus {
  # 0 - Unknown
  # 1 - StandAlone
  # 2 - Slave
  # 3 - Master
   local replica_state=$1
   echo "Send replica_state $replica_state"
   echo "replica_state $replica_state" | curl --data-binary @- http://localhost:9091/metrics/job/replica_status/instance/localhost
}

function reportReplicationSync {
    # 0 - N/A
    # 1 - NotSynced 
    # 2 - Synced
    local replica_sync_status=$1
    echo "Send replica_sync_status $replica_sync_status"
    echo "replica_sync_status $replica_sync_status" | curl --data-binary @- http://localhost:9091/metrics/job/replica_status/instance/localhost
}

function executeQueryString(){
	local query=$1
	if [ -n "$query" ]; then
			result=$(docker exec postgres psql 'postgresql://Nivshemersec:$PWD_VALUE@localhost:5432/Nivshemersec' -t -A -c "$query")
            if [[ $result == *"psql: error"* ]]; then
                echo "Error: Failed to execute query"
                reportReplicationSync 1 
            fi
    else
        reportReplicationSync 1 
    fi
	
	echo "the result of result is $result"
	if [ -z "$result" ]; then
		echo "result variable is null or empty"
		reportReplicationSync 1 
	else
	echo "INFO $result"
		if [[ $result == *"t"* ]]; then		
			# Post 1 to Pushgateway if result is t
			echo "Finished successfuly"
			reportReplicationSync 2 
		else
			echo "Finished with errors"
			# Post 0 to Pushgateway otherwise
			reportReplicationSync 1
		fi
	fi
	

}

function checkReplicationStatus(){
	replicaState=$(echo $REPLICA_STATE)
	
	if [ "$replicaState" == "master" ]; then
		reportReplicationStatus 3 
		executeQueryString "SELECT EXISTS (SELECT 1 FROM pg_stat_replication WHERE state = 'streaming')"
	elif [ "$replicaState" == "slave" ]; then
		reportReplicationStatus 2
		executeQueryString "SELECT pg_is_in_recovery() AND EXISTS (SELECT 1 FROM pg_stat_wal_receiver WHERE status = 'streaming')"
	elif [ "$replicaState" == "standAlone" ]; then
		reportReplicationStatus 1
		reportReplicationSync 0
	else
		echo "Error: Invalid replica state"
		reportReplicationStatus 0
		reportReplicationSync 0
	fi
}

function sendContainerErrorReplicationStatus(){
	replicaState=$(echo $REPLICA_STATE)
	
	if [ "$replicaState" == "master" ]; then
		reportReplicationStatus 3 
		reportReplicationSync 1
	elif [ "$replicaState" == "slave" ]; then
		reportReplicationStatus 2
		reportReplicationSync 1

	elif [ "$replicaState" == "standAlone" ]; then
		reportReplicationStatus 1
		reportReplicationSync 0
	else
		echo "Error: Invalid replica state"
		reportReplicationStatus 0
		reportReplicationSync 0
	fi
}

openssl aes-256-cbc -d -a -pbkdf2 -in $Nivshemer_HOME/stores/.sec_enc.env -out $Nivshemer_HOME/stores/.sec_enc1.env -pass pass:$nanop

# Extract the value of Pwd
PWD_VALUE=$(grep -oP 'Pwd=\K[^;]+' "$FILE" | head -n 1)

# Print the extracted value
#echo "Pwd value is: $PWD_VALUE"
#Loop from 1 to 10
for ((i = 1; i <= 10; i++)); do
    replicaState=$(echo $REPLICA_STATE)

    # Check if the postgres container is running
    if ! docker ps | grep -q postgres; then
        echo "Error: postgres container is not running"
        sendContainerErrorReplicationStatus
    else
		echo "Info: Check replication status"
		checkReplicationStatus
    fi
	
    sleep 30
done

rm -rf $Nivshemer_HOME/stores/.sec_enc1.env

