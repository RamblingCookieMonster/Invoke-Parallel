Import-Module -Force $PSScriptRoot\Invoke-Parallel.ps1

Describe 'Invoke-Parallel with default parameters' {
    
    It 'should out string' {
        $out = (0..10) | Invoke-Parallel -ScriptBlock { "a$_" } 
        $out.Count | Should Be 11
        $out[5][0] | Should Be 'a'
    }
}

