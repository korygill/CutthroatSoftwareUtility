<#
Copyright 2016 Cutthroat Software

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

function Update-UserConfigFile
{
    $email = $global:UserConfig.Email
    $email.Password = $email.Password | ConvertFrom-SecureString

    # create user config file
    $uc = @{}
    $uc.Version = $global:UserConfig.Version
    $uc.Email = $email
    $uc.BackupDrives = $global:UserConfig.BackupDrives
    $uc.BackupSystem = $global:UserConfig.BackupSystem

    $uc | ConvertTo-Json | Out-File -FilePath $userConfigFile

    $global:UserConfig.Email.Password = $global:UserConfig.Email.Password | ConvertTo-SecureString

    Write-Output "Updated: $userConfigFile"
    Show-UserConfigFile
}

function Show-UserConfigFile
{
    # display our config
    Write-Output "$global:CSU version $($csuVersion), configuration version $($global:ConfigurationVersion)"
    Write-Output "User Config File: $userConfigFile"
    $global:UserConfig | fl | Write-Output
}
