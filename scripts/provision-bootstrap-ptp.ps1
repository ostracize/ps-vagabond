#Requires -Version 5

<#PSScriptInfo

    .VERSION 1.0

    .GUID cad7db76-01e8-4abd-bdb9-3fca50cadbc7

    .AUTHOR psadmin.io

    .SYNOPSIS
        ps-vagabond provisioning boot

    .DESCRIPTION
        Provisioning bootstrap script for ps-vagabond

    .PARAMETER PATCH_ID
        Patch ID for the PUM image

    .PARAMETER MOS_USERNAME
        My Oracle Support Username

    .PARAMETER MOS_PASSWORD
        My Oracle Support Password

    .PARAMETER DPK_INSTALL
        Directory to use for downloading the DPK files

    .EXAMPLE
        provision-boot.ps1 -PATCH_ID 23711856 -MOS_USERNAME user@example.com -MOS_PASSWORD mymospassword -DPK_INSTALL C:/peoplesoft/dpk/fn92u020

#>

#-----------------------------------------------------------[Parameters]----------------------------------------------------------

[CmdletBinding()]
Param(
  [String]$PATCH_ID     = $env:PATCH_ID,
  [String]$DPK_INSTALL  = $env:DPK_INSTALL,
  [String]$PTP_INSTALL  = $env:PTP_INSTALL,
  [String]$PUPPET_HOME  = $env:PUPPET_HOME
)


#---------------------------------------------------------[Initialization]--------------------------------------------------------

# Valid values: "Stop", "Inquire", "Continue", "Suspend", "SilentlyContinue"
$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"
$VerbosePreference = "SilentlyContinue"

#------------------------------------------------------------[Variables]----------------------------------------------------------

$DEBUG = "true"
$computername = $env:computername

function change_to_midtier() {
  Write-Host "[${computername}][Task] Change env_type to 'midtier'"
  (Get-Content "${PUPPET_HOME}\data\defaults.yaml").replace("env_type: fulltier", "env_type: midtier") | Set-Content "${PUPPET_HOME}\data\defaults.yaml"
  (Get-Content "${PUPPET_HOME}\manifests\site.pp") -replace 'include.*', "include ::pt_role::pt_tools_deployment" | Set-Content "${PUPPET_HOME}\manifests\site.pp"
  Write-Host "[${computername}][Done] Change env_type to 'midtier'"
}

function execute_dpk_cleanup() {
  Write-Host "[${computername}][Task] Run the DPK cleanup script"
  Write-Host "DPK INSTALL: ${DPK_INSTALL}"

  Stop-Service psft* -ErrorAction SilentlyContinue
  if (get-process -name rmiregistry -ErrorAction SilentlyContinue) {
    get-process -name rmiregistry | stop-process -force
  }
  if (get-service -name "*ProcMgr*") {
    Stop-Service -name "*ProcMGR*" -ErrorAction SilentlyContinue
  }

  # Remove Git from PATH to prevent `id` error when running Puppet
  # . remove_from_PATH("C\:\\Program\ Files\\Git\\usr\\bin")
  if (Test-Path "C:\Program Files\Git\usr\bin\id.exe") {
    move-item "C:\Program Files\Git\usr\bin\id.exe" "C:\Program Files\Git\usr\bin\_id.exe"
  }

  if ($DEBUG -eq "true") {
    . "${DPK_INSTALL}/setup/psft-dpk-setup.ps1" `
      -cleanup `
      -ErrorAction SilentlyContinue
  } else {
    . "${DPK_INSTALL}/setup/psft-dpk-setup.ps1" `
      -cleanup `
      -ErrorAction SilentlyContinue 2>&1 | out-null
  }

  Write-Host "[${computername}][Done] Run the DPK cleanup script"
}

function execute_psft_dpk_setup() {

  # $begin=$(get-date)
  Write-Host "[${computername}][Task] Executing PeopleTools Patch DPK setup script"
  Write-Host "PTP INSTALL: ${PTP_INSTALL}"
  
  $cfg_home = hiera ps_config_home
  if (test-path $cfg_home) {
    remove-item "${cfg_home}" -recurse -force
  }

  if ($DEBUG -eq "true") {
    . "${PTP_INSTALL}/setup/psft-dpk-setup.ps1" `
      -dpk_src_dir=$(resolve-path $PTP_INSTALL).path `
      -env_type midtier `
      -deploy_only `
      -silent `
      -ErrorAction SilentlyContinue
  } else {
    . "${PTP_INSTALL}/setup/psft-dpk-setup.ps1" `
      -dpk_src_dir=$(resolve-path $PTP_INSTALL).path `
      -env_type midtier `
      -deploy_only `
      -silent `
      -ErrorAction SilentlyContinue 2>&1 | out-null
  }
  Write-Host "`tUpdate env:PS_HOME to the new location"
  [System.Environment]::SetEnvironmentVariable('PS_HOME', "$(hiera ps_home_location)", 'Machine');
  Write-Host "`t`tPS_HOME: $(hiera ps_home_location)"
  Write-Host "[${computername}][Done] Executing PeopleTools Patch DPK setup script"
}

. change_to_midtier
. execute_dpk_cleanup
. execute_psft_dpk_setup