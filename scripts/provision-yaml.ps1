#Requires -Version 5

<#PSScriptInfo

    .VERSION 1.0

    .GUID cad7db76-01e8-4abd-bdb9-3fca50cadbc7

    .AUTHOR psadmin.io

    .SYNOPSIS
        ps-vagabond provisioning puppet

    .DESCRIPTION
        Provisioning script for ps-vagabond to copy custom yaml and run puppet apply

    .PARAMETER PUPPET_HOME
        Puppet home directory

    .EXAMPLE
        provision-puppet.ps1 -PUPPET_HOME C:\ProgramData\PuppetLabs\puppet\etc

#>

#-----------------------------------------------------------[Parameters]----------------------------------------------------------

[CmdletBinding()]
Param(
  [String]$PUPPET_HOME = $env:PUPPET_HOME,
  [String]$PT_VERSION  = $env:PT_VERSION
)


#---------------------------------------------------------[Initialization]--------------------------------------------------------

# Valid values: "Stop", "Inquire", "Continue", "Suspend", "SilentlyContinue"
$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"
$VerbosePreference = "SilentlyContinue"

#------------------------------------------------------------[Variables]----------------------------------------------------------

$DEBUG = "false"

#-----------------------------------------------------------[Functions]-----------------------------------------------------------

function copy_customizations_file() {
  Write-Host "Copying customizations file"
  if ($PT_VERSION -eq "856") {
    if ($DEBUG -eq "true") {
      Write-Host "Copying to ${PUPPET_HOME}\data"
      Copy-Item "c:\vagrant\config\psft_customizations.yaml" "${PUPPET_HOME}\production\data\psft_customizations.yaml" -Force
    } else {
      Copy-Item "c:\vagrant\config\psft_customizations.yaml" "${PUPPET_HOME}\production\data\psft_customizations.yaml" -Force 2>&1 | out-null
    }
   }
  else {
    if ($DEBUG -eq "true") {
      Write-Host "Copying to ${PUPPET_HOME}\data"
      Copy-Item "c:\vagrant\config\psft_customizations.yaml" "${PUPPET_HOME}\data\psft_customizations.yaml" -Force
    } else {
      Copy-Item "c:\vagrant\config\psft_customizations.yaml" "${PUPPET_HOME}\data\psft_customizations.yaml" -Force 2>&1 | out-null
    }
  }
}

#-----------------------------------------------------------[Execution]-----------------------------------------------------------

. copy_customizations_file

Write-Host "YAML Sync Complete"

# $fqdn = facter fqdn
# $port = hiera pia_http_port
# $sitename = hiera pia_site_name

# Write-Host "Your login URL is http://${fqdn}:${port}/${sitename}/signon.html" -ForegroundColor White