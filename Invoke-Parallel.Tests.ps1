Import-Module -Force $PSScriptRoot\Invoke-Parallel.ps1

Describe 'Invoke-Parallel with default parameters' {
    
    It 'should out string' {
        $out = (0..10) | Invoke-Parallel -ScriptBlock { "a$_" } 
        $out.Count | Should Be 11
        $out[5][0] | Should Be 'a'
    }

    It 'execute sleep concurrently' {
        $m = Measure-Command { (1..10) | Invoke-Parallel -ScriptBlock { sleep 0.1 } }
        $m.TotalSeconds -le 1.0 | Should Be $true
    }    
}

