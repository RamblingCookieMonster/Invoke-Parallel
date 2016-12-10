[![Build status](https://ci.appveyor.com/api/projects/status/e2mfe1vf99maoe64?svg=true)](https://ci.appveyor.com/project/brow1920/invoke-parallel)

Invoke-Parallel
==========

This function will take in a script or scriptblock, and run it against specified objects(s) in parallel.  It uses runspaces, as there are many situations where jobs or PSRemoting are not appropriate.

# Instructions

```powershell
# Download and unblock the file(s).
# Dot source the file.
    . "\\Path\To\Invoke-Parallel.ps1"


# Get help for the function
    Get-Help Invoke-Parallel -Full


# Use Invoke-Parallel with variables in your session

    $Number = 2
    1..10 | Invoke-Parallel -ImportVariables -ScriptBlock { $Number * $_ }


# Use the $Using Syntax, currently restricted to PowerShell v3 and later

    $Path = 'C:\temp\'

    'Server1', 'Server2' | Invoke-Parallel {

        #Create a log file for this server, use the root $Path
        $ThisPath = Join-Path $Using:Path "$_.log"
        "Doing something with $_" | Out-File -FilePath $ThisPath -Force

    }


# Import modules found in the current session

    #From https://psremoteregistry.codeplex.com/releases/view/65928
    Import-Module PSRemoteRegistry

    $ServerList | Invoke-Parallel -ImportModules -ScriptBlock {

        $Key = 'Software\Microsoft\Windows\CurrentVersion\Policies\System'
        Get-RegValue -ComputerName $_ -Hive LocalMachine -Key $Key |
            Select ComputerName, Value, Data

    }


# Want to time out items that take too long?

    1..5 | Invoke-Parallel -RunspaceTimeout 2 -ScriptBlock {

        "Starting $_"
        Start-Sleep -Seconds $_
        "If you see this, we didn't timeout $_"
    }


# Is one thread freezing up when you time it out, and preventing your scripting from moving on?

    $ServerList | Invoke-Parallel -RunspaceTimeout 10 -NoCloseOnTimeout -ScriptBlock {

            Get-WmiObject -Class Win32_OperatingSystem -ComputerName $_ | select -Property PSComputerName, Caption, Version

    }
```

Some outdated notes and details are available on the [TechNet Galleries submission](http://gallery.technet.microsoft.com/Run-Parallel-Parallel-377fd430).

# Help!

Would love contributors, suggestions, feedback, and other help!  Split this out at the suggestion of @vors to help enable collaboration.

# Notes

* Credit to Boe Prox for [the base code](http://learn-powershell.net/2012/05/10/speedy-network-information-query-using-powershell/) this uses.  Boe has a number of references on runspaces, including the [presentation and materials here](http://learn-powershell.net/2014/06/11/norcal-powershell-user-group-presentation-on-runspaces-is-available/) and the excellent [PoshRSJob module](https://github.com/proxb/PoshRSJob); check them out!
