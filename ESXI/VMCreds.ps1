param(
    [Parameter(Mandatory=$true)]
    [securestring]$user,
    [Parameter(Mandatory=$true)]
    [securestring]$password
    )

#Write-Host $user
#Write-Host $password
# Store a credential
New-StoredCredential -Target TargetVM -UserName $user -Password $password


# Get the current script path
$scriptPath = $MyInvocation.MyCommand.Path

# Schedule the script for deletion after it exits
$scriptBlock = {
    Start-Sleep -Seconds 5  # Allow time for the script to finish execution
    Remove-Item -Path $using:scriptPath -Force
}

# Start the deletion process in a separate PowerShell session
Start-Job -ScriptBlock $scriptBlock

# Exit the current session
#Exit


# Remove a credential
#Remove-StoredCredential -Target TargetVM


# Retrieve a credential
#$credential = Get-StoredCredential -Target TargetVM
#$User = $credential.UserName
#$Password = $credential.GetNetworkCredential().Password

#Write-Host $User
#Write-Host $Password