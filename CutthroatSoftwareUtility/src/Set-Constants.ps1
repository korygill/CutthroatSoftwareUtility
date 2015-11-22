<#
Copyright 2015 Cutthroat Software

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
#>

param
(
    [Parameter(Mandatory=$false)]
    [switch]$NoConfig
)

<#
    ### Config File generation
    ###
    $version = "1.2"

    $email = @{
        'SmtpServer' = "smtp.live.com"
        'Port' = 587
        'UseSSL' = $true
        'UserName' = "email@hotmail.com"
        'Password' = "<password from credential>"
    }

    $backupDrives = @(
        @{'Description' = 'ddrive'; 'Src' = 'd:\'; 'Dst' = 'q:\D-Backup'; 'Log' = 'c:\logs\d-backup.log.txt'}
        @{'Description' = 'ldrive1'; 'Src' = 'l:\'; 'Dst' = 'q:\L-Backup'; 'Log' = 'c:\logs\l1-backup.log.txt'}
        @{'Description' = 'edrive'; 'Src' = 'e:\'; 'Dst' = 'r:\E-Backup'; 'Log' = 'c:\logs\e-backup.log.txt'}
        @{'Description' = 'ldrive2'; 'Src' = 'l:\'; 'Dst' = 'r:\L-Backup'; 'Log' = 'c:\logs\l2-backup.log.txt'}
    )

    $backupSystem = @{
        'WBAdminParams' = '-backupTarget:\\server\C-Backup -include:c: -allCritical -quiet'
        'WBAdminLogFile' = '\\server\C-Backup\backup.log.txt'
        'LogFile' = 'C:\Logs\SystemImageBackup.log.txt'
    }   

    $uc = @{}
    $uc.Version = $version
    $uc.Email = $email
    $uc.BackupDrives = $backupDrives
    $uc.BackupSystem = $backupSystem

    $json = $uc | ConvertTo-Json
    $json | Out-File "C:\Users\<username>\Documents\WindowsPowerShell\CutthroatSoftwareUtility-<username>.config.txt"
#>

function Create-UserConfig ([string]$userConfigFile)
{
    #email
    $email = @{}
    $in = Read-Host "Enter your smtp server (smtp.live.com)"
    $email.SmtpServer = $in

    $in = Read-Host "Enter your smtp server port (587)"
    $email.Port = $in

    $choices = @()
    $choices += ,@("&Yes", "Uses SSL.")
    $choices += ,@("&No", "Does not use SSL.")

    $in = [boolean](Get-Choice -Caption "SMTP Security" -Message "Use SSL for SMTP mail server?" -ChoiceList $choices -Default 0)
    $email.UseSSL = !$in

    $in = Get-Credential -Message "Enter your email address and password.`nIf you use two-factor authentication, use an app password."
    $email.UserName = $in.UserName
    $email.Password = $in.Password | ConvertFrom-SecureString

    #backup drives
    $backupDrives = @(
        @{'Description' = 'ddrive'; 'Src' = 'd:\'; 'Dst' = 'q:\D-Backup'; 'Log' = 'c:\logs\d-backup.log.txt'}
        @{'Description' = 'ldrive1'; 'Src' = 'l:\'; 'Dst' = 'q:\L-Backup'; 'Log' = 'c:\logs\l1-backup.log.txt'}
        @{'Description' = 'edrive'; 'Src' = 'e:\'; 'Dst' = 'r:\E-Backup'; 'Log' = 'c:\logs\e-backup.log.txt'}
        @{'Description' = 'ldrive2'; 'Src' = 'l:\'; 'Dst' = 'r:\L-Backup'; 'Log' = 'c:\logs\l2-backup.log.txt'}
    )

    #backup system
    $backupSystem = @{
        'WBAdminParams' = '-backupTarget:\\server\C-Backup -include:c: -allCritical -quiet'
        'WBAdminLogFile' = '\\server\C-Backup\backup.log.txt'
        'LogFile' = 'C:\Logs\SystemImageBackup.log.txt'
    }   

    # create user config file
    $uc = @{}
    $uc.Version = $global:ConfigurationVersion
    $uc.Email = $email
    $uc.BackupDrives = $backupDrives
    $uc.BackupSystem = $backupSystem

    $uc | ConvertTo-Json | Out-File -FilePath $userConfigFile

    # warning
    $msg =  "!!! NOTE !!! : Default backup settings have been defined in your user configuration file.`n" +
        "You must edit these sections manually before continuing to use all functionality successfully.`n" +
        "File: $userConfigFile`n" +
        "Press ENTER to continue"
    Read-Host $msg | Out-Null

    return $uc
}


function global:MaybeOutputExceptionAndThrow([string]$exception)
{
    if ($global:IsNonInteractive)
    {
        Write-Output $exception
    }

    throw $exception
}


# Main Script
###
try {
    set-strictmode -version Latest
    $global:VerbosePreference = "SilentlyContinue"
    $global:ErrorActionPreference = "Stop"
    $global:CSU = "CutthroatSoftwareUtility"
    $global:ModulePath = Join-Path "$home\Documents\WindowsPowerShell\Modules" $global:CSU
    $global:IsNonInteractive = [bool]([Environment]::GetCommandLineArgs() -like '-noni*')
    # Increase this version only if you change the configuration members
    $global:ConfigurationVersion = "1.2"

    # do not declare any $global vars after here
    if ($NoConfig) 
    {
        return
    }

    $userConfigFile = Join-Path "$home\Documents\WindowsPowerShell" ($global:CSU + "-" + $env:USERNAME + ".config.txt")

    $scriptPath = Split-Path -LiteralPath $(if ($PSVersionTable.PSVersion.Major -ge 3) { $PSCommandPath } else { & { $MyInvocation.ScriptName } })

    $csuVersion = (Test-ModuleManifest (Join-Path $PSScriptRoot ("$global:CSU" + ".psd1")) | Select-Object Version).Version.ToString()

    if (!(Test-Path -Path $userConfigFile))
    {
        Import-Module (Join-Path $scriptPath Get-Choice.psm1) -Verbose -Force

        $global:UserConfig = Create-UserConfig $userConfigFile
    }
    else 
    {
        # user constants exist, read them
        $global:UserConfig = Get-Content -Path $userConfigFile | ConvertFrom-Json
    }

    # make password a secure string
    $global:UserConfig.Email.Password = ($global:UserConfig.Email.Password | ConvertTo-SecureString)

    # display our config
    Write-Output "$global:CSU version $($csuVersion), configuration version $($global:ConfigurationVersion)"
    Write-Output "User Config File: $userConfigFile"
    $global:UserConfig | fl | Write-Output

    # if script not same as data file, bail out
    if ($global:UserConfig.Version -ne $global:ConfigurationVersion)
    {
        "Version mismatch. Backup your config file, delete the original, then run again and re-enter your configuration information"
        throw "Version mismatch"
        # todo: support migration
        #$global:UserConfig = Create-UserConfig $userConfig
    }
}
catch 
{
    MaybeOutputExceptionAndThrow $_
}
