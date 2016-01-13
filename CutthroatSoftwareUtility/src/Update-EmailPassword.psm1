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

function Update-EmailPassword
{
    $in = Get-Credential -UserName $global:UserConfig.Email.UserName -Message "Enter your email address and password.`nIf you use two-factor authentication, use an app password."

    if ($in -ne $null)
    {
        $global:UserConfig.Email.Password = $in.Password

        Update-UserConfigFile
    }
}

Export-ModuleMember -Function Update-EmailPassword
