Import-Module -Force $PSScriptRoot\Invoke-Parallel.ps1

Describe 'Invoke-Parallel with default parameters' {
    
    It 'should out string' {
        $out = (0..10) | Invoke-Parallel -ScriptBlock { "a$_" } 
        $out.Count | Should Be 11
        $out[5][0] | Should Be 'a'
    }

    It 'should output runspace errors to error stream' {
        $out = 0 | Invoke-Parallel -ErrorVariable OutError -ErrorAction SilentlyContinue -ScriptBlock {
            Write-Error "A Fake Error!"
        }
        $out.Count | Should Be 0
        $OutError[0].ToString() | Should Be "A Fake Error!"
    }

    It 'should import variables with one letter name' {
        $a = "Hello"
        $out = 0 | Invoke-Parallel -ImportVariables -ScriptBlock {
            $a
        } | Should Be "Hello"
    }

    It 'should import all variables' {
        $a = "Hello"
        $longvar = "World!"
        $out = 0 | Invoke-Parallel -ImportVariables -ScriptBlock {
            "$a $longvar"
        }
        $out | Should Be "Hello World!"
    }
}

