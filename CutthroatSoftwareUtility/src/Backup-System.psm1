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

function Backup-System
{
    $cmd="WBAdmin start backup " + $global:UserConfig.BackupSystem.WBAdminParams

    "Running backup system`nCommand: $cmd" | Tee-Object -FilePath $global:UserConfig.BackupSystem.LogFile

    $Error.Clear()

    $duration = Measure-Command {Invoke-Expression $cmd | Out-File $global:UserConfig.BackupSystem.WBAdminLogFile}

    "Duration: $duration" |
    Tee-Object -FilePath $global:UserConfig.BackupSystem.LogFile -Append

    if($?) 
    { 
        "Backup sytem (success)" | Tee-Object -FilePath $global:UserConfig.BackupSystem.LogFile -Append
    }
    else {
        "Backup sytem (failed)" | Tee-Object -FilePath $global:UserConfig.BackupSystem.LogFile -Append
    }
}

function Start-BackupSystem
{
    try 
    {
        $allOutput = Backup-System
        Write-Host ($allOutput -join "`n")

        # foreach line, match, and measure sum
        $sCount = ($allOutput | % { ($_ -match "(success)") } | Measure-Object -Sum).Sum
        $fCount = ($allOutput | % { ($_ -match "(failed)") } | Measure-Object -Sum).Sum

        $subject = "BackupSystem: Success: $sCount, Failed: $fCount, $(Get-Date)"
        $body = "$allOutput`n`n"

        Write-Output ("=" * 50)
        Write-Output "$subject`n$body"

        Send-EMail -Subject $subject -Body $body
    }
    catch
    {
        MaybeOutputExceptionAndThrow $_
    }
}

#Export-ModuleMember -Function Backup-System
Export-ModuleMember -Function Start-BackupSystem
