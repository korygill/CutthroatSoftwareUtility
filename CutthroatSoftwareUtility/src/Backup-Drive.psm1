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

function Backup-Drive
{
    param
    (
        [Parameter(Mandatory=$true, Position=0)]
        $SrcPath,
        [Parameter(Mandatory=$true, Position=1)]
        $DstPath,
        [Parameter(Mandatory=$true, Position=2)]
        $LogFile
    )
    
    try {
        $params='/MIR /XD "$RECYCLE.BIN" "System Volume Information"'

        # ensures path ends with \
        $src=$($SrcPath.TrimEnd('\')) + '\'
        $dst=$($DstPath.TrimEnd('\')) + '\'
        $cmd="robocopy " + $src + " " + $dst + " $params"
    
        "Running backup for $SrcPath`nCommand: $cmd" | Tee-Object -FilePath $LogFile
    
        $duration = Measure-Command {Invoke-Expression $cmd 1>> $LogFile}

        "Duration: $duration" |
        Tee-Object -FilePath $LogFile -Append

        # Ensure $DstPath is visible due to bug in Robocopy hiding destination dirs
        attrib -s -h (Resolve-Path $DstPath).Path.TrimEnd('\')

        "Backup for $SrcPath (success)" | Tee-Object -FilePath $LogFile -Append
    }
    catch
    {
        "Backup for $SrcPath (failed)`n$_" | Tee-Object -FilePath $LogFile -Append
    }
    finally
    {
        Write-Output "Logfile: $LogFile"
    }
}

function Start-BackupAllDrives
{
    try 
    {
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        $allOutput = @()

        foreach ($backup in $global:UserConfig.BackupDrives)
        {
            $bRet = Backup-Drive $backup.Src $backup.Dst $backup.Log
            Write-Host ($bRet -join "`n")

            $allOutput += $bRet
            $allOutput += "`n"
        }

        $stopwatch.Stop()

        # foreach line, match, and measure sum
        $sCount = ($allOutput | % { ($_ -match "(success)") } | Measure-Object -Sum).Sum
        $fCount = ($allOutput | % { ($_ -match "(failed)") } | Measure-Object -Sum).Sum

        $subject = "BackupAllDrives: Success: $sCount, Failed: $fCount, $(Get-Date)"

        $body = $allOutput -join "`n"
        $body += "Total duration: $($stopwatch.Elapsed.ToString())"

        Write-Output ("=" * 50)
        Write-Output "$subject`n$body"

        Send-EMail -Subject $subject -Body $body
    }
    catch
    {
        MaybeOutputExceptionAndThrow $_
    }
}

#Export-ModuleMember -Function Backup-Drive
Export-ModuleMember -Function Start-BackupAllDrives