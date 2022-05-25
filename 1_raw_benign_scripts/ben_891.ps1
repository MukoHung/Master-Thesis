while($true)
{
	$lastMinute = (Get-Date).AddMinutes(-1)
	$files = Get-ChildItem .\rec\*.ts
	$counter = 0

	# Converting Files
	ForEach ($file in $files) {
		$filename = $file.BaseName
		
		$counter++
		Write-Progress -Activity "Converting files" -CurrentOperation $filename -PercentComplete (($counter / $files.count) * 100)
		
		if ($file.LastWriteTime -gt $lastMinute)
		{
			Write-Error -Message "File is currently in use" -Category PermissionDenied -CategoryTargetName $filename
		}
		else
		{
			$newname = [io.path]::ChangeExtension($file, "mp4")
			ffmpeg -hide_banner -loglevel warning -i "$file" -c copy "$newname"
			Remove-Item -LiteralPath $file
		}
	}
	
	# Moving Files
	Write-Progress -Activity "Moving files"
	Get-ChildItem -Path ".\rec\*.mp4" | Move-Item -Destination ".\done"
	
	# Waiting
	$seconds = 900
	1..$seconds | ForEach-Object {
		$percent = $_ * 100 / $seconds; 
		Write-Progress -Activity "Waiting $seconds seconds" -SecondsRemaining $($seconds - $_) -PercentComplete $percent; 
		Start-Sleep -Seconds 1
	}
}