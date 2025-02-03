#!/bin/bash

# Set the name of the VM
VM_NAME="mot"

# Set the NFS share location
NFS_SHARE="/vmfs/volumes/nfs/"

# Function to create a timestamp
timestamp() {
  date +"%Y%m%d%H%M%S"
}


# Find the VM ID using vim-cmd
VM_ID=$(vim-cmd vmsvc/getallvms | grep "$VM_NAME" | awk '{print $1}')


while true; do
  # Locate the path of the "mot" VM
  VM_PATH=$(find /vmfs/volumes -type d -name "$VM_NAME" -print )

  if [ -z "$VM_PATH" ]; then
    echo "VM '$VM_NAME' not found in /vmfs/volumes."
  else
    # Create a snapshot with a timestamp
    SNAPSHOT_NAME="$VM_NAME-$(timestamp)"
	vim-cmd vmsvc/snapshot.create $VM_ID "$SNAPSHOT_NAME" "Snapshot created by script"
    echo "Created snapshot: $SNAPSHOT_NAME"
    

  fi

  # Sleep for 2 minutes before the next snapshot
  sleep 10
    # Copy VM files to NFS share
	echo "Copied VM files to NFS share: $NFS_SHARE"
    cp -r $VM_PATH/* $NFS_SHARE/
  sleep 180
done
