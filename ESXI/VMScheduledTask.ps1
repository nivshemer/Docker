param(
    [Parameter(Mandatory=$true)]
    [string]$ESXiHost,
    [Parameter(Mandatory=$true)]
    [string]$vmName
    )
	
	
$currentDirectory = $PWD.Path
Write-Host "Current directory: $currentDirectory"


Set-Location $pwd
$scriptPath = "$pwd\VMScheduledTask.ps1"


if (Test-Path $scriptPath)
{
    Write-Host "File exists: $scriptPath"
}
else 
{
    Write-Host "File does not exist: $scriptPath"
    exit 1
}


# Read the content of the text file
$content = Get-Content -Path $pwd\VMSnapShot.ps1

$newContent = $content -replace "100.110.120.65", $ESXiHost -replace "FTMachine", $vmName

# Write the modified content back to the text file
$newContent | Set-Content -Path $pwd\VMSnapShot.ps1


#Create new ScheduledTask

$taskName = "AutoVMBackup"

$existingTask = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue

if ($existingTask -ne $null) {
    # Modify the task properties here
    $newAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File '$pwd\VMSnapShot.ps1'"
    Set-ScheduledTask -TaskName $taskName -Action $newAction
    Write-Host "The task '$taskName' has been modified."
} else {
    Write-Host "The task '$taskName' does not exist."
}

#Store a credential
.\VMCreds.ps1

$trigger = New-ScheduledTaskTrigger -Daily -At "01:00" # Adjust the time as needed

$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File $pwd\VMSnapShot.ps1"

Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName #-User "Username" -Password "Password"




