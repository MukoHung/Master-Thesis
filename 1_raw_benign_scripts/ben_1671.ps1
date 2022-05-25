# Get a list of meetings occurring today.
function get-meetings() {
	$olFolderCalendar = 9
	$ol = New-Object -ComObject Outlook.Application
	$ns = $ol.GetNamespace('MAPI')
	$Start = (Get-Date).ToShortDateString()
	$End = (Get-Date).ToShortDateString()
	$Filter = "[MessageClass]='IPM.Appointment' AND [Start] > '$Start' AND [End] < '$End'"
	$appointments = $ns.GetDefaultFolder($olFolderCalendar).Items
	$appointments.IncludeRecurrences = $true
	$appointments.Restrict($Filter) |  
	ForEach-Object {
		if ($_.IsRecurring -ne $true) {
			# send the meeting down the pipeline
			$_; 
		} else {
			#"RECURRING... see if it occurs today?"
			try {
				# This will throw an exception if it's not on today. (Note how we combine today's *date* with the start *time* of the meeting)
				$_.GetRecurrencePattern().GetOccurrence( ((Get-Date).ToString("yyyy-MM-dd") + " " + $_.Start.ToString("HH:mm")) )
				# but if it is on today, it will send today's occurrence down the pipeline.
			} 
			catch
			{
				#"Not today"
			}
		}
	} | Sort-Object -property Start | ForEach-Object { 
		# split up the names of the attendees to have just 1 firstname/surname and less space.
		$arrr = $_.RequiredAttendees.split(';') |
			ForEach-Object { $_.Trim() } |
			ForEach-Object { $_.split(' ')[1] + ' ' + $_.split(' ')[0] };
		$attendees = ($arrr -join " ").Replace(", ",",").TrimEnd(',')
		# this is the formatted string that we return, ready for use in 'today'
		("`n`t`t[ ] " + $_.Start.ToString("HH:mm") + " - " + $_.Subject.ToUpper() + " with: " + $attendees )  
	}
}