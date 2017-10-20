[CmdletBinding()]
Param (
    [Parameter(Mandatory=$True, Position=1)]
    [String]$PuppetMasterHostname,
    [Parameter(Mandatory=$True, Position=2)]
    [String]$PuppetMasterPort,
    [Parameter(Mandatory=$false, Position=3)]
    [String]$Environment    
)

Start-BitsTransfer "https://downloads.puppetlabs.com/windows/puppet-agent-x64-latest.msi" -Destination "$($env:TEMP)"

$MSIArguments = @( 
	"/qn",
	"/norestart"
	"/i",
	"$($env:TEMP)\puppet-agent-x64-latest.msi",
	"PUPPET_MASTER_SERVER=$($PuppetMasterHostname)"
	)

Write-Host "Installing Puppet with arguments: $($MSIArguments)"
$process = Start-Process -FilePath msiexec.exe -ArgumentList $MSIArguments -Wait -PassThru
if ($process.ExitCode -ne 0) {
    Write-Host "Installer failed with code $($process.ExitCode)"
    Exit 1
}

$puppetExe = "C:\Program Files\Puppet Labs\Puppet\bin\puppet.bat"

Start-Process -FilePath $puppetExe -ArgumentList @("config", "set", "masterport", $PuppetMasterPort) -Wait -PassThru

if ($Environment) {
	Start-Process -FilePath $puppetExe -ArgumentList @("config", "set", "environment", $Environment) -Wait -PassThru
}
