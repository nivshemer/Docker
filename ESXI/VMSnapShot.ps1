
[string]$ESXiHost = "100.110.120.65"
[string]$vmName = "FTmachine"


# Retrieve a credential
$credential = Get-StoredCredential -Target TargetVM
$User = $credential.UserName
$Password = $credential.GetNetworkCredential().Password

$retentionPolicy = 7
#Install-Module -Name VMware.PowerCLI

# Connect to your vCenter server or ESXi host
Connect-VIServer -Server $ESXiHost -User $User -Password $Password 
$snapshotName = "FT_$(Get-Date -Format 'yyyyMMddHHmmss')"

# Get the VM
$vm = Get-VM -Name $vmName

# Create the snapshot
New-Snapshot -VM $vm -Name $snapshotName -Memory:$true -Quiesce:$true

# Get all snapshots for the VM and sort them by creation date
$snapshots = Get-Snapshot -VM $vm | Sort-Object -Property Created

# Calculate the number of snapshots to delete based on the retention policy
$snapshotsToDelete = $snapshots | Select-Object -Skip $retentionPolicy

# Delete excess snapshots
$snapshotsToDelete | ForEach-Object {
    Remove-Snapshot -Snapshot $_ -Confirm:$false -RunAsync
    Write-Host "Deleted snapshot: $($_.Name)"
}


# Get the VM
$vm = Get-VM -Name $vmName

# Get all snapshots for the VM
$snapshots = Get-Snapshot -VM $vm

# Loop through snapshots and display their names and sizes
foreach ($snapshot in $snapshots) {
    $snapshotName = $snapshot.Name
    $snapshotSizeGB = $snapshot.SizeGB
    Write-Host "Snapshot: $snapshotName, Size: $snapshotSizeGB GB"
}


# Disconnect from the vCenter server or ESXi host
Disconnect-VIServer -Confirm:$false
