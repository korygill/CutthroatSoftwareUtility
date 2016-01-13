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

function Send-EMail
{
    param 
    (
        [Parameter(Mandatory=$true, Position=0)]
        [String]$Subject,
        [Parameter(Mandatory=$true, Position=1)]
        [String]$Body
    )

    try 
    {
        $params = @{
            'To' = $global:UserConfig.Email.UserName
            'From' = $global:UserConfig.Email.UserName
            'SmtpServer' = $global:UserConfig.Email.SmtpServer
            'Port' = $global:UserConfig.Email.Port
            'Credential' = New-Object System.Management.Automation.PSCredential($global:UserConfig.Email.UserName,$global:UserConfig.Email.Password)
            'Subject' = $Subject
            'Body' = $Body
        }

        if ($global:UserConfig.Email.UseSSL) 
        {
            $params['UseSSL'] = $true
        }

        Send-MailMessage @params
    }
    catch
    {
        MaybeOutputExceptionAndThrow $_
    }
}

Export-ModuleMember -Function Send-EMail
