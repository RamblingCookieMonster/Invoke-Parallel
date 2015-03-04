#handle PS2
if(-not $PSScriptRoot)
{
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}

$PSVersion = $PSVersionTable.PSVersion.Major
Import-Module -Force $PSScriptRoot\..\Invoke-Parallel

Describe 'Invoke-Parallel' {
    
    Context 'Strict mode' { 

        Set-StrictMode -Version latest

        It 'should out string' {
            $out = (0..10) | Invoke-Parallel { "a$_" } 
            $out.Count | Should Be 11
            $out[5][0] | Should Be 'a'
        }

        It 'should output runspace errors to error stream' {
            $out = 0 | Invoke-Parallel -ErrorVariable OutError -ErrorAction SilentlyContinue {
                Write-Error "A Fake Error!"
            }
            $out | Should Be $null
            $OutError[0].ToString() | Should Be "A Fake Error!"
        }

        It 'should import variables with one letter name' {
            $a = "Hello"
            0 | Invoke-Parallel -ImportVariables {
                $a
            } | Should Be "Hello"
        }

        It 'should import all variables' {
            $a = "Hello"
            $longvar = "World!"
            0 | Invoke-Parallel -ImportVariables {
                "$a $longvar"
            } | Should Be "Hello World!"
        }

        It 'should not import variables when not specified' {
            $a = "Hello"
            $longvar = "World!"
            0 | Invoke-Parallel {
                "$a $longvar"
            } | Should Be " "
        }

        It 'should import modules' {
            0 | Invoke-Parallel -ImportModules {
                Get-Module Pester
            } | Should not Be $null
        }

        It 'should not import modules when not specified' {
            0 | Invoke-Parallel {
                Get-Module Pester
            } | Should Be $null
        }

        It 'should honor time out' {
            $timeout = $null
            0 | Invoke-Parallel -RunspaceTimeout 1 -WarningVariable TimeOut {
                Start-Sleep -Seconds 2
            }
            $timeout | Should Match "Runspace timed out at*"

        }

        It 'should pass in a specified variable as $parameter' {
            $a = 5
            0 | Invoke-Parallel -Parameter $a {
                $parameter
            } | Should Be 5

        }

    }
}

