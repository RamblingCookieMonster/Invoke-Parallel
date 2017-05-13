Install-Module PSDepend -Force
Invoke-PSDepend -Force -verbose

# For PS2, after installing with PS5.
Move-Item C:\temp\pester\*\* -Destination C:\temp\pester -force