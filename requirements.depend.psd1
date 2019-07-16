@{
    PSDependOptions = @{
        Target = 'C:\Temp'
    }

    Psake           = @{
        Parameters = @{
            Force  = $True
            Import = $True
        }
        # Addes target (C:\temp) to psmodulepath
        AddToPath  = $True
    }
    PSDeploy        = 'latest'
    Pester          = 'latest'
    BuildHelpers    = 'latest'
}
