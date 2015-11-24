# Cutthroat Software Utilities #

Cutthroat Software Utilities are helpful PowerShell functions and scripts for keeping your computer backed up, showing diagnostic information, and more.

**WARNING: use these tools at your own risk**. The author and maintainers are not responsible for any damage caused to your files as a result of using these tools. Always manually code review changes made by the tools and always use a version control system.

## Configuration ##

Copy files to your Modules directory like normal, or run .\deploy.ps1 from the tools directory.  When you import Cutthroat Software Utilities for the first time (ipmo CutthroatSoftwareUtilities, shortcut "ipmo cut`tab`"), you will get prompted for some information, and some other defaults will get created. This step caches your email credential securely by saving the secure string for your password. Everything else is a straightforward edit to suit your environment.

## Commands ##

	Get-Choice
	Start-BackupAllDrives
	Start-BackupSystem
	Send-EMail

### Get-Choice ###

Allows the user to select from a list of choices, returns a number to indicate the selected item.

	$choices = @()
    $choices += ,@("&Yes", "Uses SSL.")
    $choices += ,@("&No", "Does not use SSL.")

    $in = [boolean](Get-Choice -Caption "SMTP Security" -Message "Use SSL for SMTP mail server?" -ChoiceList $choices -Default 0)
    $uc.UseSSL = !$in

##### What the user sees: #####

    SMTP Security
    Use SSL for SMTP mail server?
    [Y] Yes  [N] No  [?] Help (default is "Y"): ?
    Y - Uses SSL.
    N - Does not use SSL.
    [Y] Yes  [N] No  [?] Help (default is "Y"): 

### Start-BackupAllDrives ###

Performs a backup of drives using *robocopy.exe*.

### Start-BackupSystem ###

Performs a backup of the system using *wbadmin.exe*.

### Send-EMail ###

Wrapper for Send-Mail that uses cached credentials for the current user to send SMTP mail.

## Project dependencies ##

* Visual Studio
* [PowerShell Tools for Visual Studio](http://adamdriscoll.github.io/poshtools/)

## Things used in this project ##

#### A list of things used in this project that people may want to inspire from in their own projects.

PowerShell, script and module deployment, sending email, cached credentials, JSON, arrays, hashes, robocopy, wbadmin, $Host.ui.PromptForChoice, scheduled tasks, modules, NonInteractive detection, logging, parameter splatting, complex command lines, System.Diagnostics.Stopwatch, help files,
... and more ...

## Sample usage and default configuration ##

Below is a representation of the default configuration, which also shows how these tools can be used to maintain backup copies of data across drives.

	Disks [Drives]:	
	
	Data drives   Backup drives
	|-------|     |-------------|
	|   C   | ==> | Q:\C-Backup |
	|       |     | \\srv\share | 
	|-------|     |-------------| 

	|-------|     |-------------|
	| D | L | ==> | Q:\D-Backup |
	|-------|     |-------------|

	|-------|     |-------------|
	| E | L | ==> | R:\E-Backup |
	|-------|     |-------------|

	|+++++++|     |-------------|
	|   L   | ==> | Q:\L-Backup |
	|       | ==> | R:\L-Backup |
	|+++++++|     |-------------|
	
	|-------|
	| Q | L |
	|-------|

	|-------|
	| R | L |
	|-------|

	^ C: backs up to a UNC path to control where the
	     backup goes (not in root, makes restore nicer)
	Start-BackupSystem

	^ L: is a stripe across disk D, E, Q, R
	     (so back it up on both Q & R)
    Start-BackupAllDrives
 
Using the above, the focus is protecting the data across D, E, and L drives.  If C: fails, get a new SSD for the system drive and recover the OS using system restore. If any other drive fails, replacing and restoring the data is straightforward. There are many ways to approach this...use what works for you.

To see how to set up the scheduled tasks to run `get-help about_cutthroatsoftwareutility` from PowerShell.