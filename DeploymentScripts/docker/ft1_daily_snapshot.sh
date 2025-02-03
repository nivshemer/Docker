#!/bin/bash

VM_NAME="FT1"
SNAPSHOT_NAME="Snapshot-$(date +\%Y\%m\%d)"

/usr/bin/VBoxManage snapshot $VM_NAME take "$SNAPSHOT_NAME" --description "Auto Snapshot"
echo "snapshot written $SNAPSHOT_NAME" >> /nanolock/log.txt
