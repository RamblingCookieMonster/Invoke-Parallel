Install-Module -Name PSDepend -Force
Invoke-PSDepend -Force -Verbose

# For PS2, after installing with PS5.
Move-Item -Path C:\temp\pester\*\* -Destination C:\temp\pester -Force
