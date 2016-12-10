# This script will invoke pester tests
# It should invoke on PowerShell v2 and later
# We serialize XML results and pull them in appveyor.yml

#If Finalize is specified, we collect XML output, upload tests, and indicate build errors
param(
    [switch]$Finalize,
    [switch]$Test,
    [string]$ProjectRoot = $ENV:APPVEYOR_BUILD_FOLDER
)

#Initialize some variables, move to the project root
    $Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
    $PSVersion = $PSVersionTable.PSVersion.Major
    $TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"

    $Address = "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)"
    Set-Location $ProjectRoot

    $Verbose = @{}
    if($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master")
    {
        $Verbose.add("Verbose",$True)
    }
   
#Run a test with the current version of PowerShell, upload results
    if($Test)
    {
        "`n`tSTATUS: Testing with PowerShell $PSVersion`n"

    #If Powershell version 3 or higher, import pester module as usual.
        if($PSVersionTable.PSVersion.Major -gt 2)
        {
            Import-Module Pester
        }
    #If Powershell version 2, look for the latest version of pester module and import with full file paths.
        elseif($PSVersionTable.PSVersion.Major -eq 2)
        {
            $PesterModule = gci "C:\Program Files\WindowsPowerShell\Modules\Pester" | ? { $_.PSIsContainer } | sort Name -desc | select -f 1 | Select -ExpandProperty FullName
            $pesterPsd1 = Join-Path $PesterModule "\Pester.psd1"
            $pesterPsm1 = Join-Path $PesterModule "\Pester.psm1"
            Import-Module $pesterPsd1
            Import-Module $pesterPsm1
        }

        Invoke-Pester @Verbose -Path "$ProjectRoot\Tests" -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile" -PassThru |
            Export-Clixml -Path "$ProjectRoot\PesterResults_PS$PSVersion`_$Timestamp.xml"
        
        If($env:APPVEYOR_JOB_ID)
        {
            (New-Object 'System.Net.WebClient').UploadFile( $Address, "$ProjectRoot\$TestFile" )
        }
    }

#If finalize is specified, display errors and fail build if we ran into any
    If($Finalize)
    {
        #Show status...
            $AllFiles = Get-ChildItem -Path $ProjectRoot\PesterResults*.xml | Select -ExpandProperty FullName
            "`n`tSTATUS: Finalizing results`n"
            "COLLATING FILES:`n$($AllFiles | Out-String)"

        #What failed?
            $Results = @( Get-ChildItem -Path "$ProjectRoot\PesterResults_PS*.xml" | Import-Clixml )
            
            $FailedCount = $Results |
                Select -ExpandProperty FailedCount |
                Measure-Object -Sum |
                Select -ExpandProperty Sum
    
            if ($FailedCount -gt 0) {

                $FailedItems = $Results |
                    Select -ExpandProperty TestResult |
                    Where {$_.Passed -notlike $True}

                "FAILED TESTS SUMMARY:`n"
                $FailedItems | ForEach-Object {
                    $Item = $_
                    [pscustomobject]@{
                        Describe = $Item.Describe
                        Context = $Item.Context
                        Name = "It $($Item.Name)"
                        Result = $Item.Result
                    }
                } |
                    Sort Describe, Context, Name, Result |
                    Format-List

                throw "$FailedCount tests failed."
            }
    }