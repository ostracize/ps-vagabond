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
  [String]$MOS_USERNAME = $env:MOS_USERNAME,
  [String]$MOS_PASSWORD = $env:MOS_PASSWORD,
  [String]$DPK_INSTALL  = $env:DPK_INSTALL
)


#---------------------------------------------------------[Initialization]--------------------------------------------------------

# Valid values: "Stop", "Inquire", "Continue", "Suspend", "SilentlyContinue"
$ErrorActionPreference = "Stop"
$DebugPreference = "SilentlyContinue"
$VerbosePreference = "SilentlyContinue"

#------------------------------------------------------------[Variables]----------------------------------------------------------

$DEBUG = "false"

function execute_psft_dpk_setup() {

  # $begin=$(get-date)
  Write-Host "Executing DPK setup script"
  Write-Host "DPK INSTALL: ${DPK_INSTALL}"
  if ($DEBUG -eq "true") {
    . "${DPK_INSTALL}/setup/psft-dpk-setup.ps1" `
      -dpk_src_dir=$(resolve-path $DPK_INSTALL).path `
      -silent `
      -no_env_setup
  } else {
    . "${DPK_INSTALL}/setup/psft-dpk-setup.ps1" `
      -dpk_src_dir=$(resolve-path $DPK_INSTALL).path `
      -silent `
      -no_env_setup 2>&1 | out-null
  }
}

. execute_psft_dpk_setup