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

param
(
    [Parameter(Mandatory=$false)]
    [switch]$Force,
    [Parameter(Mandatory=$false)]
    [switch]$Clean
)

# main script

$ErrorActionPreference = "Stop"

Write-Host "Deloying..."

try
{
    $scriptPath = Split-Path -LiteralPath $(if ($PSVersionTable.PSVersion.Major -ge 3) { $PSCommandPath } else { & { $MyInvocation.ScriptName } })
    $src = (Join-Path (Split-Path $scriptPath) 'src')

    . (Join-Path $src Set-Constants.ps1) -NoConfig

    "src = $src"
    "ModulePath = $global:ModulePath"

    if (!(Test-Path $global:ModulePath))
    {
        New-Item -ItemType Directory | Out-Null
    }
    else
    {
        if ($Clean)
        {
            if (!$Force)
            {
                $caption = "Delete Directory"
                $message = "Do you want to delete the '$($global:ModulePath)' folder?"

                $choices = @()
                $choices += ,@("&Yes", "Deletes all the files in the folder.")
                $choices += ,@("&No", "Retains all the files in the folder.")

                # default option 1, no
                Import-Module (Join-Path $src Get-Choice.psm1) -Verbose -Force
                $result = Get-Choice $caption $message $choices 1

                switch ($result)
                {
                    0 {"Removing folder..."}
                    1 {"Exiting..."; return}
                }
            }

            Get-ChildItem -Path $global:ModulePath -Include * -Recurse | Remove-Item -Recurse
        }
    }

    Copy-Item -Path "$src\*" -Filter * -Destination $global:ModulePath -Recurse -Force

    Import-Module $global:ModulePath -Verbose -Global -Force
}
finally
{
    Write-Host "...Done."
}
