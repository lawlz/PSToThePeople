<#
        .Synopsis
           This will backup or restore yo stuff to drive/system
        .DESCRIPTION
            TODO:  Make this easily extensible
                        
            The default behavior of this command is to backup to an external hard drive.  
            
            If you don't pass the -restore flag, then it will act like it is a backup command and create the windowsBackup folder in what it determines an appropriate location.

        Dependencies: nope i hope...
        
        Resources: googs

        AUTHOR: JimmyJames

        .EXAMPLE
           backup-system.ps1 -fromDrive D:\ -toDrive C:\ -restore -liveRun

           This command will restore from an external or OS drive.  The script will try and determine using folder names in the from drive location

        .EXAMPLE
            backup-system.ps1 -fromDrive D:\ -toDrive C:\

            This command, since it is missing the 'liveRun' parameter, will run this script but not back anything up.
#>


param (
    [parameter(Mandatory=$false,Valuefrompipeline=$true,Position=0)][string]$fromDrive,
    [parameter(Mandatory=$false,Valuefrompipeline=$true,Position=1)][string]$toDrive,
    [parameter(Mandatory=$false,Valuefrompipeline=$true,Position=2)][switch]$restore,
    [parameter(Mandatory=$false,Valuefrompipeline=$true,Position=3)][switch]$liveRun
    )

function check-drive {
    param (
        [parameter(Mandatory=$false,Valuefrompipeline=$true)][string]$drive,
        [parameter(Mandatory=$false,Valuefrompipeline=$true)][switch]$find
        )
    # we want to make sure that we entered a good drive letter
    do {
        $isProperDrive = $false
        if($find) {
            #build an array of drives mounted, only lettered
            $mounts = @()
            get-psdrive |where-object {$_.Root -match '^[c-zC-Z]:\\'} | foreach-object {$mounts += $_.root }
            write-host "Mount options to choose from:  $mounts `n"
            #something neat
            #gci -Recurse -Path .\ |  ForEach-Object {write-host $_.pspath.replace("Microsoft.PowerShell.Core\FileSystem::","")}
            # however we are doing it with a function
            $mountCount =$mounts.count
            $drive = create-menu -counter $mountCount -mountPoints $mounts
            $find = $false
        }
        elseif($drive -match '^[c-zC-Z]:\\') {
            write-host "Your drive choice is $drive"
            $isProperDrive = $true
        }
        else {
            write-host "#### You did not choose a valid drive.  Your input was:  $drive  #####" -ForegroundColor yellow
            write-host "#### Choose something like 'E:\'  #####`n" -ForegroundColor yellow
            remove-variable drive
            $find = $true
        }
    }until ($isProperDrive)
    return $drive
}

function create-menu{
    param (
        [parameter(Mandatory=$true,Valuefrompipeline=$true,Position=0)][int]$counter,
        [parameter(Mandatory=$true,Valuefrompipeline=$true,Position=1)]$mountPoints
        )
    # now we need to create a string builder of some sort to build a dynamic menu.
    $total = 0
    do {
        foreach ($mount in $mountPoints) {
            $total++
            write-host "Entering $total chooses this mount point: $mount"
        }
    } until ($total -eq $counter)
    $answered = $false
    do {
        $answer = read-host "Which option do you choose?"
        # what in the world was just passed in
        $isInt = $answer -match '^\d+$'
        if ($isInt){
            if ($answer -le $counter) {
                $answered = $true
                # make sure we get the right index
                $answer = $answer - 1
                return $mountPoints[$answer]
            }
        } 
        else {
            write-host "you did not put in a valid number, enter one of the options above" -ForegroundColor red -BackgroundColor black

        }
    } until ($answered)
}

function create-path {
    param (
        [parameter(Mandatory=$true,Valuefrompipeline=$true,Position=0)][string]$path
        )
    
    if (test-path $path){
        continue
    }
    else {
        write-host "Creating directory $path`n" -foregroundColor yellow 
        write-host "Is this the first time backing up to this drive hopefully`n" -foregroundColor yellow 
        new-item -itemtype "directory" -path $path
    }
}

function run-backup {
    param (
        [parameter(Mandatory=$true,Valuefrompipeline=$true,Position=0)]$fromPath,
        [parameter(Mandatory=$true,Valuefrompipeline=$true,Position=1)]$toPath
        )
    
    if (!(test-path $toPath)) {
        create-path -Path $topath
    }
    #TODO  Ask for folders to backup from.
    [array]$folders = ("Documents","Music","Favorites",".ssh",".vscode")  # <-- potentially add these as well
    foreach ($folder in $folders) {
        write-host "`n`t##########################`nNow Copying from:"$fromPath"\"$folder -ForegroundColor black -BackgroundColor green -NoNewline
        write-host "`n`nTo:"$toPath"\"$folder"`n`t##########################" -ForegroundColor black -BackgroundColor darkgreen
        # now to see if the folder is really a folder and not a file...
        if (test-path -PathType leaf $($fromPath+"\"+$folder)) {
            write-host "Currently referencing a file." -ForegroundColor yellow
            if ($liveRun) {
                copy-item -Path $($fromPath+"\"+$folder) -Destination $toPath -Verbose
            }
            else {
                copy-item -Path $($fromPath+"\"+$folder) -Destination $toPath -Verbose -whatif
            }
        }
        # do this if it is a folder
        elseif (test-path -PathType container $($fromPath+"\"+$folder)) {
            if ($liveRun) {
                if ($verbose) {
                    robocopy $fromPath"\"$folder $toPath"\"$folder /COPY:DAT /S /XO /FP /ETA /V /R:5 /W:5
                }
                else {
                    write-host "Output is not in verbose mode, no verbose flag set, copy details are omitted" -ForegroundColor yellow
                    robocopy $fromPath"\"$folder $toPath"\"$folder /COPY:DAT /S /XO /R:5 /W:5 /ETA /XO /NFL /NP /NC /NS /NDL /NJH /NJS
                }
            }
            else {
                write-host "This job would have copied from: $fromPath\$folder`n" -ForegroundColor yellow
                write-host "To this destination:  $toPath\$folder`n" -ForegroundColor yellow
                robocopy $fromPath"\"$folder $toPath"\"$folder /S /L /COPY:DAT /XO /NFL /NP /NC /NS /NDL /ETA
            }
        }
        # if not a folder or a file, then what are you?
        else {
            write-host "`n`t##########################`n`n`tSource File not found, skipping`n`n`t##########################" -ForegroundColor red -BackgroundColor black
        }
    }
}
#if not stated, then assume local machine
if(!$restore) {
    write-host "#### Checking source drive for device backup.  #####" -ForegroundColor yellow
    if ($fromDrive) {
        $fromComputer = check-drive -drive $fromDrive
    }
    else {
        write-host "#### You did not choose a source.  #####" -ForegroundColor yellow
        $fromComputer = $env:HOMEDRIVE + "\"
        write-host "Default will use your local drive, $fromComputer as the source for the data to copy from`n"
    }
}
# else find out where to restore this from
elseif($restore){
    write-host "#### Checking source drive for data restoration.  #####" -ForegroundColor yellow
    #check for proper drive
    if ($fromDrive) {
        $fromComputer = check-drive -drive $fromDrive
    }
    else {
        write-host "#### No source drive choice for data restoration, prompting for choice.  #####" -ForegroundColor yellow
        $fromComputer = check-drive -find
    }
    if (!$toDrive) {
        write-host "#### You did not choose a destination for this restore job.  #####" -ForegroundColor yellow
        $toDrive = $env:HOMEDRIVE + "\"
        write-host "Default will use your local drive, $toDrive as the destination for the data to copy to`n"
    }
    
}
if(!$toDrive) {
    write-host "#### You did not choose a destination drive for this backup/restore.  #####" -ForegroundColor yellow
    $toComputer = check-drive -find
}
else {
    write-host "#### Validating drive to backup/restore to.  #####" -ForegroundColor yellow
    $toComputer = check-drive -drive $toDrive
}

#get the current username
$username = $env:USERNAME
#now check if this is a restore or backup
# default is backing up to external HDD
if ($restore) {
    #check to see if we are restoring from hdd or backup drive
    $folders = gci -Attributes D -Path $fromComputer
    if (($folders | sls users) -and ($folders | sls windows)){
        write-host "This seems to be a backup from another OS" -ForegroundColor yellow
        $copyFrom = $fromComputer + "users\" + $username
        $copyTo = $toComputer + "users\" + $username
        run-backup -fromPath $copyFrom -toPath $copyTo
    }
    elseif (($folders | sls WindowsBackup)) {
        write-host "You are choosing to restore from a backup hdd" -ForegroundColor yellow
        $copyFrom = $fromComputer + "WindowsBackup\" + $username
        $copyTo = $toComputer + "users\" + $username
        run-backup -fromPath $copyFrom -toPath $copyTo
    }
}
else {
    $folders = gci -Attributes D -Path $toComputer
    # now build out your path variables
    if (($folders | select-string "WindowsBackup")) {
        write-host "`n#####`tThis seems to be a backup to the backup drive.`t#####" -ForegroundColor yellow
        $copyTo = $toComputer + "WindowsBackup\" + $username
        $copyFrom = $fromComputer + "users\" + $username
        run-backup -fromPath $copyFrom -toPath $copyTo
    }
    elseif (($folders | select-string "users|Windows")){
        write-host "`n#####`tThis seems to be a backup to another OS.`t#####" -ForegroundColor yellow
        $copyFrom = $fromComputer + "users\" + $username
        $copyTo = $toComputer + "users\" + $username
        run-backup -fromPath $copyFrom -toPath $copyTo
    }
}
# check if test or not
if ( -not $liveRun) {
    write-host "`nThis was just a test run, in order to do the backup/restore pass the 'runLive' parameter`n`tSee help for details`n" -ForegroundColor yellow
}
