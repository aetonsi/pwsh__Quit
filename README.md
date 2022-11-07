# pwsh__Quit
Powershell tool to stop processes with the given name.

# Usage
```powershell
# First import the module
Import-Module ./Quit.psm1

# Then you can use the imported function
Invoke-Quit -im notepad
# or, killing the process if it does not gracefully exits
Invoke-Quit -im notepad -force
# or, with more verbose output
Invoke-Quit -im notepad -vvv
# or, using taskkill.exe (windows) to kill the process if necessary
Invoke-Quit -im notepad -force -taskkill


# The function will return a boolean, $true if the process(es) was found and it exited, $false otherwise.
```
