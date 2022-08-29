function Exited {
	Param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)] [array] $processes
	)

	return ($processes | ForEach-Object { $_.refresh(); $_ } | Where-Object { $_.HasExited }).count -eq $processes.count
}


function Invoke-Quit {
	Param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)] [string] $im, # image (process) name
		[Parameter(Mandatory = $false)] [switch] $force, # kill processes forcefully
		[Parameter(Mandatory = $false)] [switch] $vvv, # -Verbose === -vvv
		[Parameter(Mandatory = $false)] [switch] $taskkill # uses taskkill.exe instead of Stop-Process when $force=$true
	)

	$vvv = $vvv -or $PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent;

	$processes = Get-Process -Name $im -ErrorAction SilentlyContinue
	if ($processes -isnot [system.array]) {
		$processes = @($processes)
	}

	if ($processes) {
		if ($vvv) {
			"Killing: $im"
			$procStr = ($processes | Format-List | Out-String)
			if ($procStr -eq "") { $procStr = "<none>" }
			"Found processes to kill:`n$($procStr.Trim())"
		}

		# try gracefully first
		foreach ($process in $processes) {
			$process.CloseMainWindow() >$null
		}
		Start-Sleep 1

		# check that the count of processes at the beginning is equal to the count of processes that have exited
		$exited = Exited $processes

		# forcefully close processes if needed
		if (!$exited -and $force) {
			if ($vvv) {
				Write-Warning "Process did not exit gracefully, killing it..."
			}
			if ($taskkill) {
				# get unique process names (needed because a process might already have been killed by a previous taskkill.exe call)
				$uniqueProcessesNames = $processes | ForEach-Object { $_.Name } | Get-Unique
				foreach ($procName in $uniqueProcessesNames) {
					& taskkill.exe -im "${procName}.exe" -f
				}
			}
			else {
				$processes | Stop-Process -Force
			}
		}

		# check that the count of processes at the beginning is equal to the count of processes that have exited
		$exited = Exited $processes

		return $exited
	}
 else {
		if ($vvv) {
			Write-Warning "No process found with im=$im"
		}
		return $false
	}
}

Export-ModuleMember -Function Invoke-Quit
