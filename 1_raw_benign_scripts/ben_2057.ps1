<#
.Synopsis
	Pipe binary data between processes' Standard Output and Standard Input streams.
    Can read input stream from file and save resulting output stream to file.

.Description
	Pipe binary data between processes' Standard Output and Standard Input streams.
    Can read input stream from file/pipeline and save resulting output stream to file.
	Requires PsAsync module: http://psasync.codeplex.com

.Notes
	Author: beatcracker (https://beatcracker.wordpress.com, https://github.com/beatcracker)
	License: Microsoft Public License (http://opensource.org/licenses/MS-PL)

.Component
	Requires PsAsync module: http://psasync.codeplex.com

.Parameter Command
	An array of hashtables, each containing Command Name, Working Directory and Arguments

.Parameter InFile
	This parameter is optional.

	A string representing path to file, to read input stream from.

.Parameter OutFile
	This parameter is optional.

	A string representing path to file, to save resulting output stream to.

.Parameter Append
	This parameter is optional. Default is false.

	A switch controlling wheither ovewrite or append output file if it already exists. Default is to overwrite.

.Parameter IoTimeout
	This parameter is optional. Default is 0.

	A number of seconds to wait if Input/Output streams are blocked. Default is to wait indefinetely.

.Parameter ProcessTimeout
	This parameter is optional. Default is 0.

	A number of seconds to wait for process to exit after finishing all pipeline operations. Default is to wait indefinetely.
    Details: https://msdn.microsoft.com/en-us/library/ty0d8k56.aspx

.Parameter BufferSize
	This parameter is optional. Default is 4096.

	Size of buffer in bytes for read\write operations. Supports standard Powershell multipliers: KB, MB, GB, TB, and PB.
    Total number of buffers is: Command.Count * 2 + InFile + OutFile.

.Parameter ForceGC
	This parameter is optional.

	A switch, that if specified will force .Net garbage collection.
    Use to immediately release memory on function exit, if large buffer size was used.

.Parameter RawData
	This parameter is optional.

    By default function returns object with StdOut/StdErr streams and process' exit codes.
	If this switch is specified, function will return raw Standard Output stream.

.Example
	Invoke-RawPipeline -Command @{Path = 'findstr.exe' ; Arguments = '/C:"Warning" /I C:\Windows\WindowsUpdate.log'} -OutFile 'C:\WU_Warnings.txt'

    Batch analog: findstr.exe /C:"Warning" /I C:\Windows\WindowsUpdate.log' > C:\WU_Warnings.txt

.Example
	Invoke-RawPipeline -Command @{Path = 'findstr.exe' ; WorkingDirectory = 'C:\Windows' ; Arguments = '/C:"Warning" /I .\WindowsUpdate.log'} -RawData

    Batch analog: cd /D C:\Windows && findstr.exe /C:"Warning" /I .\WindowsUpdate.log

.Example
	'TestString' | Invoke-RawPipeline -Command @{Path = 'find.exe' ; Arguments = '/I "test"'} -OutFile 'C:\SearchResult.log'

    Batch analog: echo TestString | find /I "test" > C:\SearchResult.log

.Example
	Invoke-RawPipeline -Command @{Path = 'ipconfig'}, @{Path = 'findstr' ; Arguments = '/C:"IPv4 Address" /I'} -RawData

    Batch analog: ipconfig | findstr /C:"IPv4 Address" /I

.Example
	Invoke-RawPipeline -InFile 'C:\RepoDumps\Repo.svn' -Command @{Path = 'svnadmin.exe' ; Arguments = 'load'}

    Batch analog: svnadmin load < C:\RepoDumps\MyRepo.dump
#>

function Invoke-RawPipeline
{
	[CmdletBinding()]
	Param
	(
        [Parameter(ValueFromPipeline = $true)]
		[ValidateNotNullOrEmpty()]
        [ValidateScript({
            if($_.psobject.Methods.Match.('ToString'))
            {
                $true
            }
            else
            {
                throw 'Can''t convert pipeline object to string!'
            }
        })]
        $InVariable,

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[ValidateScript({
			$_ | ForEach-Object {
				$Path = $_.Path
				$WorkingDirectory = $_.WorkingDirectory

				if(!(Get-Command -Name $Path -CommandType Application -ErrorAction SilentlyContinue))
                {
                    throw "Command not found: $Path"
                }

				if($WorkingDirectory)
				{
					if(!(Test-Path -LiteralPath $WorkingDirectory -PathType Container -ErrorAction SilentlyContinue))
					{
						throw "Working directory not found: $WorkingDirectory"
					}
				}
			}
			$true
		})]
		[ValidateNotNullOrEmpty()]
		[array]$Command,

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[ValidateScript({
			if(!(Test-Path -LiteralPath $_))
			{
				throw "File not found: $_"
			}
			$true
		})]
		[ValidateNotNullOrEmpty()]
		[string]$InFile,

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[ValidateScript({
			if(!(Test-Path -LiteralPath (Split-Path $_)))
			{
				throw "Folder not found: $_"
			}
			$true
		})]
		[ValidateNotNullOrEmpty()]
		[string]$OutFile,

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[switch]$Append,

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[ValidateRange(0, 2147483)]
		[int]$IoTimeout = 0,

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[ValidateRange(0, 2147483)]
		[int]$ProcessTimeout = 0,

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[long]$BufferSize = 4096,

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[switch]$RawData,

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[switch]$ForceGC
	)

	Begin
	{

		$Modules = @{PsAsync = 'http://psasync.codeplex.com'}

        'Loading modules:', ($Modules | Format-Table -HideTableHeaders -AutoSize | Out-String) | Write-Verbose

		foreach($module in $Modules.GetEnumerator())
		{
			if(!(Get-Module -Name $module.Key))
			{
				Try
				{ 
					Import-Module -Name $module.Key -ErrorAction Stop
				}
				Catch
				{
					throw "$($module.Key) module not available. Get it here: $($module.Value)"
				}
			}
		}

		function New-ConsoleProcess
		{
			Param
			(
				[string]$Path,
				[string]$Arguments,
				[string]$WorkingDirectory,
				[switch]$CreateNoWindow = $true,
				[switch]$RedirectStdIn = $true,
				[switch]$RedirectStdOut = $true,
				[switch]$RedirectStdErr = $true
			)

			if(!$WorkingDirectory)
			{
				if(!$script:MyInvocation.MyCommand.Path)
				{
					$WorkingDirectory = [System.AppDomain]::CurrentDomain.BaseDirectory
				}
				else
				{
					$WorkingDirectory = Split-Path $script:MyInvocation.MyCommand.Path
				}
			}

			Try
			{
				$ps = New-Object -TypeName System.Diagnostics.Process -ErrorAction Stop
				$ps.StartInfo.Filename = $Path
				$ps.StartInfo.Arguments = $Arguments
				$ps.StartInfo.UseShellExecute = $false
				$ps.StartInfo.RedirectStandardInput = $RedirectStdIn
				$ps.StartInfo.RedirectStandardOutput = $RedirectStdOut
				$ps.StartInfo.RedirectStandardError = $RedirectStdErr
				$ps.StartInfo.CreateNoWindow = $CreateNoWindow
				$ps.StartInfo.WorkingDirectory = $WorkingDirectory
			}
			Catch
			{
				throw $_
			}

			return $ps
		}

		function Invoke-GarbageCollection
		{
			[gc]::Collect()
			[gc]::WaitForPendingFinalizers()
		}

        $CleanUp = {
		    $IoWorkers + $StdErrWorkers |
		    ForEach-Object {
			    $_.Src, $_.Dst |
			    ForEach-Object {
				    if(!($_ -is [System.Diagnostics.Process]))
				    {
					    Try
					    {
						    $_.Close()
					    }
					    Catch
					    {
						    Write-Error "Failed to close $_"
					    }
					    $_.Dispose()
				    }

			    }
		    }
        }

		$PumpData = {
			Param
			(
				[hashtable]$Cfg
			)
			# Fail hard, we don't want stuck threads
			$Private:ErrorActionPreference = 'Stop'

			$Src = $Cfg.Src
			$SrcEndpoint = $Cfg.SrcEndpoint
			$Dst = $Cfg.Dst
			$DstEndpoint = $Cfg.DstEndpoint
			$BufferSize = $Cfg.BufferSize
			$SyncHash = $Cfg.SyncHash
			$RunspaceId = $Cfg.Id
            
			# Setup Input and Output streams
			if($Src -is [System.Diagnostics.Process])
			{
				switch ($SrcEndpoint)
				{
					'StdOut' {$InStream = $Src.StandardOutput.BaseStream}
					'StdIn' {$InStream = $Src.StandardInput.BaseStream}
					'StdErr' {$InStream = $Src.StandardError.BaseStream}
					default {throw "Not valid source endpoint: $_"}
				}
			}
			else
			{
				$InStream = $Src
			}

			if($Dst -is [System.Diagnostics.Process])
			{
				switch ($DstEndpoint)
				{
					'StdOut' {$OutStream = $Dst.StandardOutput.BaseStream}
					'StdIn' {$OutStream = $Dst.StandardInput.BaseStream}
					'StdErr' {$OutStream = $Dst.StandardError.BaseStream}
					default {throw "Not valid destination endpoint: $_"}
				}
			}            
			else
			{
				$OutStream = $Dst
			}

            $InStream | Out-String | ForEach-Object {$SyncHash.$RunspaceId.Status += "InStream: $_"}
            $OutStream | Out-String | ForEach-Object {$SyncHash.$RunspaceId.Status += "OutStream: $_"}

			# Main data copy loop
			$Buffer = New-Object -TypeName byte[] $BufferSize
			$BytesThru = 0

			Try
			{
				Do
				{
					$SyncHash.$RunspaceId.IoStartTime = [DateTime]::UtcNow.Ticks
					$ReadCount = $InStream.Read($Buffer, 0, $Buffer.Length)
					$OutStream.Write($Buffer, 0, $ReadCount)
					$OutStream.Flush()
					$BytesThru += $ReadCount
				}
				While($readCount -gt 0)
			}
			Catch
			{
                $SyncHash.$RunspaceId.Status += $_
            
			}
			Finally
			{
				$OutStream.Close()
				$InStream.Close()
			}
		}
	}

	Process
	{
        $PsCommand = @()
		if($Command.Length)
		{
		    Write-Verbose 'Creating new process objects'
		    $i = 0
		    foreach($cmd in $Command.GetEnumerator())
		    {
			    $PsCommand += New-ConsoleProcess @cmd
			    $i++
		    }
		}

		Write-Verbose 'Building I\O pipeline'
		$PipeLine = @()
        if($InVariable)
        {
                [Byte[]]$InVarBytes = [Text.Encoding]::UTF8.GetBytes($InVariable.ToString())
                $PipeLine += New-Object -TypeName System.IO.MemoryStream -ArgumentList $BufferSize -ErrorAction Stop
                $PipeLine[-1].Write($InVarBytes, 0, $InVarBytes.Length)
                [Void]$PipeLine[-1].Seek(0, 'Begin')
        }
		elseif($InFile)
		{
			$PipeLine += New-Object -TypeName System.IO.FileStream -ArgumentList ($InFile, [IO.FileMode]::Open) -ErrorAction Stop
		    if($PsCommand.Length)
		    {
			    $PsCommand[0].StartInfo.RedirectStandardInput = $true
            }
		}
		else
		{
		    if($PsCommand.Length)
		    {
			    $PsCommand[0].StartInfo.RedirectStandardInput = $false
            }
		}

		$PipeLine += $PsCommand

		if($OutFile)
		{
		    if($PsCommand.Length)
		    {
			    $PsCommand[-1].StartInfo.RedirectStandardOutput = $true
            }

			if($Append)
			{
				$FileMode = [System.IO.FileMode]::Append
			}
			else
			{
				$FileMode = [System.IO.FileMode]::Create
			}

			$PipeLine += New-Object -TypeName System.IO.FileStream -ArgumentList ($OutFile, $FileMode, [System.IO.FileAccess]::Write) -ErrorAction Stop
		}
		else
		{
		    if($PsCommand.Length)
		    {
                $PipeLine += New-Object -TypeName System.IO.MemoryStream -ArgumentList $BufferSize -ErrorAction Stop
            }
		}
        
		Write-Verbose 'Creating I\O threads'
		$IoWorkers = @()
		for($i=0 ; $i -lt ($PipeLine.Length-1) ; $i++)
		{
			$SrcEndpoint = $DstEndpoint = $null
			if($PipeLine[$i] -is [System.Diagnostics.Process])
			{
				$SrcEndpoint = 'StdOut'
			}
			if($PipeLine[$i+1] -is [System.Diagnostics.Process])
			{
				$DstEndpoint = 'StdIn'
			}

			$IoWorkers += @{
				Src = $PipeLine[$i]
				SrcEndpoint = $SrcEndpoint
				Dst = $PipeLine[$i+1]
				DstEndpoint = $DstEndpoint
			}
		}
		Write-Verbose "Created $($IoWorkers.Length) I\O worker objects"

		Write-Verbose 'Creating StdErr readers'
		$StdErrWorkers = @()
		for($i=0 ; $i -lt $PsCommand.Length ; $i++)
		{
			$StdErrWorkers += @{
				Src = $PsCommand[$i]
				SrcEndpoint = 'StdErr'
				Dst = New-Object -TypeName System.IO.MemoryStream -ArgumentList $BufferSize -ErrorAction Stop
			}
		}
		Write-Verbose "Created $($StdErrWorkers.Length) StdErr reader objects"

		Write-Verbose 'Starting processes'
		$PsCommand |
		    ForEach-Object {
			    $ps = $_
			    Try
			    {
				    [void]$ps.Start()
			    }
			    Catch
			    {
                    Write-Error "Failed to start process: $($ps.StartInfo.FileName)"
				    Write-Verbose "Can't launch process, killing and disposing all"

				    if($PsCommand)
				    {
					    $PsCommand |
					        ForEach-Object {
						        Try{$_.Kill()}Catch{} # Can't do much if kill fails...
						        $_.Dispose()
					        }
				    }

                        Write-Verbose 'Closing and disposing I\O streams'
                    . $CleanUp
			    }
			    Write-Verbose "Started new process: Name=$($ps.Name), Id=$($ps.Id)"
		    }

		$WorkersCount = $IoWorkers.Length + $StdErrWorkers.Length
		Write-Verbose 'Creating sync hashtable'
		$sync = @{}
		for($i=0 ; $i -lt $WorkersCount ; $i++)
		{
            $sync += @{$i = @{IoStartTime = $nul ; Status = $null}}
		}
		$SyncHash = [hashtable]::Synchronized($sync)

		Write-Verbose 'Creating runspace pool'
		$RunspacePool = Get-RunspacePool $WorkersCount

		Write-Verbose 'Loading workers on the runspace pool'
		$AsyncPipelines = @()
		$i = 0
		$IoWorkers + $StdErrWorkers |
		ForEach-Object {
			$Param = @{
				BufferSize = $BufferSize
				Id = $i
				SyncHash = $SyncHash
			} + $_

			$AsyncPipelines += Invoke-Async -RunspacePool $RunspacePool -ScriptBlock $PumpData -Parameters $Param
			$i++

			Write-Verbose 'Started working thread'
			$Param | Format-Table -HideTableHeaders -AutoSize | Out-String | Write-Debug
		}

		Write-Verbose 'Waiting for I\O to complete...'
		if($IoTimeout){Write-Verbose "Timeout is $IoTimeout seconds"}

		Do
		{
			# Check for pipelines with errors
			[array]$FailedPipelines = Receive-AsyncStatus -Pipelines $AsyncPipelines | Where-Object {$_.Completed -and $_.Error}
			if($FailedPipelines)
			{
				"$($FailedPipelines.Length) pipeline(s) failed!",
				($FailedPipelines | Select-Object -ExpandProperty Error | Format-Table -AutoSize | Out-String) | Write-Debug
			}

			if($IoTimeout)
			{
				# Compare I\O start time of thread with current time
				[array]$LockedReaders = $SyncHash.Keys | Where-Object {[TimeSpan]::FromTicks([DateTime]::UtcNow.Ticks - $SyncHash.$_.IoStartTime).TotalSeconds -gt $IoTimeout}
				if($LockedReaders)
				{
					# Yikes, someone is stuck
					"$($LockedReaders.Length) I\O operations reached timeout!" | Write-Verbose
					$SyncHash.GetEnumerator() | ForEach-Object {"$($_.Key) = $($_.Value.Status)"} | Sort-Object | Out-String | Write-Debug
					$PsCommand | ForEach-Object {
						Write-Verbose "Killing process: Name=$($_.Name), Id=$($_.Id)"
						Try
						{
							$_.Kill()
						}
						Catch
						{
							Write-Error 'Failed to kill process!'
						}
					}
					break
				}
			}
			Start-Sleep 1
		}
		While(Receive-AsyncStatus -Pipelines $AsyncPipelines | Where-Object {!$_.Completed}) # Loop until all pipelines are finished

		Write-Verbose 'Waiting for all pipelines to finish...'
		$IoStats = Receive-AsyncResults -Pipelines $AsyncPipelines
		Write-Verbose 'All pipelines are finished'

		Write-Verbose 'Collecting StdErr for all processes'
		$PipeStdErr = $StdErrWorkers |
		    ForEach-Object {
			    $Encoding = $_.Src.StartInfo.StandardOutputEncoding
			    if(!$Encoding)
			    {
				    $Encoding = [System.Text.Encoding]::Default
			    }
			    @{
				    FileName = $_.Src.StartInfo.FileName
				    StdErr = $Encoding.GetString($_.Dst.ToArray())
				    ExitCode = $_.Src.ExitCode
			    }
		    } | 
                Select-Object   @{Name = 'FileName' ; Expression = {$_.FileName}},
						        @{Name = 'StdErr' ; Expression = {$_.StdErr}},
						        @{Name = 'ExitCode' ; Expression = {$_.ExitCode}}

        if($IoWorkers[-1].Dst -is [System.IO.MemoryStream])
        {
		    Write-Verbose 'Collecting final pipeline output'
                if($IoWorkers[-1].Src -is [System.Diagnostics.Process])
                {
			        $Encoding = $IoWorkers[-1].Src.StartInfo.StandardOutputEncoding
                }
			    if(!$Encoding)
			    {
				    $Encoding = [System.Text.Encoding]::Default
			    }
                $PipeResult = $Encoding.GetString($IoWorkers[-1].Dst.ToArray())
        }


		Write-Verbose 'Closing and disposing I\O streams'
		. $CleanUp

		$PsCommand |
			ForEach-Object {
				$_.Refresh()
				if(!$_.HasExited)
				{
					Write-Verbose "Process is still active: Name=$($_.Name), Id=$($_.Id)"
					if(!$ProcessTimeout)
					{
						$ProcessTimeout = -1
					}
					else
					{
						$WaitForExitProcessTimeout = $ProcessTimeout * 1000
					}
					Write-Verbose "Waiting for process to exit (Process Timeout = $ProcessTimeout)"
					if(!$_.WaitForExit($WaitForExitProcessTimeout))
					{
						Try
						{
							Write-Verbose 'Trying to kill it'
							$_.Kill()
						}
						Catch
						{
							Write-Error "Failed to kill process $_"
						}
					}
				}
				Write-Verbose "Disposing process object: Name=$($_.StartInfo.FileName)"
				$_.Dispose()
			}

		Write-Verbose 'Disposing runspace pool'
		# http://stackoverflow.com/questions/21454252/how-to-cleanup-resources-in-a-dll-when-powershell-ise-exits-like-new-pssession
		$RunspacePool.Dispose()

		if($ForceGC)
		{
			Write-Verbose 'Forcing garbage collection'
			Invoke-GarbageCollection
		}
        
        if(!$RawData)
        {
            New-Object -TypeName psobject -Property @{Result = $PipeResult ; Status = $PipeStdErr}
        }
        else
        {
            $PipeResult
        }
	}
}