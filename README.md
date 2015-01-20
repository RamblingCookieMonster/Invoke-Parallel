Invoke-Parallel
==========

This function will take in a script or scriptblock, and run it against specified objects(s) in parallel.  It uses runspaces, as there are many situations where jobs or PSRemoting are not appropriate.

# Instructions

    #Download and unblock the file(s).
    #Dot source the file.
    . "\\Path\To\Invoke-Parallel.ps1"
    
    #Get help for the function
    Get-Help Invoke-Parallel -Full

    #Use Invoke-Parallel
    $Number = 2
		1..10 | Invoke-Parallel -ImportVariables -ScriptBlock { $Number * $_ }
  
Some outdated notes and details are available on the [TechNet Galleries submission](http://gallery.technet.microsoft.com/Run-Parallel-Parallel-377fd430).

# Help!

Would love contributors, suggestions, feedback, and other help!  Split this out at the suggestion of @vors to help enable collaboration.

# Notes

* Credit to Boe Prox for [the base code](http://learn-powershell.net/2012/05/10/speedy-network-information-query-using-powershell/) this uses.  Boe has a number of references on runspaces, including the [presentation and materials here](http://learn-powershell.net/2014/06/11/norcal-powershell-user-group-presentation-on-runspaces-is-available/); check them out!