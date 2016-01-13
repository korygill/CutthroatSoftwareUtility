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

function Get-Choice
{
<# 
     .Synopsis
        Allows the user to select from a list of choices, returns a number to indicate the selected item. 

    .Description 

        Displays a caption followed by a message, and the options are then
        displayed one after the other, and the user can choose one.

    .Example 

        $caption = "Delete Directory"
        $message = "Do you want to delete the '$($junk)' folder?"

        $choices = @()
        $choices += ,@("&Yes", "Deletes all the files in the folder.")
        $choices += ,@("&No", "Retains all the files in the folder.")

        # default option 1, no
        $result = Get-Choice $caption $message $choices 1

        switch ($result)
        {
            0 {"Removing folder..."}
            1 {"Exiting..."; return}
        }

        What the user sees:

        Delete Directory
        Do you want to delete the 'C:\junk' folder?
        [Y] Yes  [N] No  [?] Help (default is "N"): ?
        Y - Deletes all the files in the folder.
        N - Retains all the files in the folder.
        [Y] Yes  [N] No  [?] Help (default is "N"): n

    .Example

        $choices = @()
        $choices += ,@("&Yes", "Uses SSL.")
        $choices += ,@("&No", "Does not use SSL.")

        $in = [boolean](Get-Choice -Caption "SMTP Security" -Message "Use SSL for SMTP mail server?" -ChoiceList $choices -Default 0)
        $uc.UseSSL = !$in

        What the user sees:

        SMTP Security
        Use SSL for SMTP mail server?
        [Y] Yes  [N] No  [?] Help (default is "Y"): ?
        Y - Uses SSL.
        N - Does not use SSL.
        [Y] Yes  [N] No  [?] Help (default is "Y"):

    .Parameter Caption

        The First line of text displayed

     .Parameter Message

        The Second line of text displayed

    .Parameter ChoiceList

        An array of an array of strings, each one is possible choice/help pair. The hot key in each choice must be prefixed with an & sign.

    .Parameter Default

        The zero based item in the array which will be the default choice if the user hits enter.
#> 

    param 
    (
        [Parameter(Mandatory=$true, Position=0)]
        [String]$Caption,
        [Parameter(Mandatory=$true, Position=1)]
        [String]$Message,
        [Parameter(Mandatory=$true, Position=2)]
        [String[][]]$ChoiceList,
        [Parameter(Mandatory=$true, Position=3)]
        [int]$Default
    )

    $choices = New-Object System.Collections.ObjectModel.Collection[System.Management.Automation.Host.ChoiceDescription]

    $ChoiceList | % {$choices.Add((New-Object "System.Management.Automation.Host.ChoiceDescription" -ArgumentList @($_)))}
    $Host.ui.PromptForChoice($Caption, $Message, $choices, $Default)
}

Export-ModuleMember -Function Get-Choice
