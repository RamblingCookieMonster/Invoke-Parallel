# This script will invoke pester tests
# It should invoke on PowerShell v2 and later
# We serialize XML results and pull them in appveyor.yml

#If Finalize is specified, we collect XML output, upload tests, and indicate build errors
param (
    [switch]$Finalize,
    [switch]$Test,
    [string]$ProjectRoot = $ENV:APPVEYOR_BUILD_FOLDER
)

#Initialize some variables, move to the project root
$Timestamp = Get-Date -uformat "%Y%m%d-%H%M%S"
$PSVersion = $PSVersionTable.PSVersion.Major
$TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"

$Address = "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)"
Set-Location -Path $ProjectRoot

$Verbose = @{ }
if ($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master") {
    $Verbose.add("Verbose", $True)
}

#Run a test with the current version of PowerShell, upload results
if ($Test) {
    "`n`tSTATUS: Testing with PowerShell $PSVersion`n"

    Import-Module -Name Pester

    Invoke-Pester @Verbose -Path "$ProjectRoot\Tests" -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile" -PassThru |
        Export-Clixml -Path "$ProjectRoot\PesterResults_PS$PSVersion`_$Timestamp.xml"

    If ($env:APPVEYOR_JOB_ID) {
        (New-Object -TypeName 'System.Net.WebClient').UploadFile( $Address, "$ProjectRoot\$TestFile" )
    }
}

#If finalize is specified, display errors and fail build if we ran into any
If ($Finalize) {
    #Show status...
    $AllFiles = Get-ChildItem -Path $ProjectRoot\PesterResults*.xml | Select-Object -ExpandProperty FullName
    "`n`tSTATUS: Finalizing results`n"
    "COLLATING FILES:`n$($AllFiles | Out-String)"

    #What failed?
    $Results = @( Get-ChildItem -Path "$ProjectRoot\PesterResults_PS*.xml" | Import-Clixml )

    $FailedCount = $Results |
        Select-Object -ExpandProperty FailedCount |
        Measure-Object -Sum |
        Select-Object -ExpandProperty Sum

    if ($FailedCount -gt 0) {
        $FailedItems = $Results |
            Select-Object -ExpandProperty TestResult |
            Where-Object -FilterScript { $_.Passed -notlike $True }

        "FAILED TESTS SUMMARY:`n"
        $FailedItems | ForEach-Object {
            $Item = $_
            [PSCustomObject]@{
                Describe = $Item.Describe
                Context  = $Item.Context
                Name     = "It $($Item.Name)"
                Result   = $Item.Result
            }
        } |
        Sort-Object -Property Describe, Context, Name, Result |
        Format-List
        throw "$FailedCount tests failed."
    }
}
