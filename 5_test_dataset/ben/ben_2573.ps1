<#
    .SYNOPSIS
        A custom command channel to generate emails from Office 365 Alert Context data
    .DESCRIPTION
        This script is used as a command channel to generate alert emails from the data
        stored in the Alert Context tab of the Office 365 Message Center alerts. There
        is no simple way to retrieve this data as that tab is more or less free form, 
        so the data is pulled from SCOM, filtered for New resolution state and then
        send to the lsit of email addresses.
    .PARAMETER SmtpHost
        The hostname of the server to send mail from
    .PARAMETER SmtpPort
        The port to communicate over (default 25)
    .PARAMETER Sender
        The email address that will be sent from 
    .PARAMETER Recipients
        One or more email addresses to send to
    .EXAMPLE
        New-SCOMChannelO365.ps1 -AlertId '$Data/Context/DataItem/AlertId$'  -SmtpHost smtp.company.com -Sender ScomAccount@company.com -Recipients @('Administrator;admin@company.com','User;user@company.com')

        Description
        -----------
        This is the basic setup for using this script, please see the Notes section 
        for more details about configuration within SCOM.
    .NOTES
        ScriptName : New-SCOMChannelO365.ps1
        Created By : jspatton
        Date Coded : 11-03-2014 10:40:42

        Operations Manager Setup
        ------------------------
        Full path to command file
        C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe

        Command line parameters
        -Command "& '"C:\Scripts\New-SCOMChannelO365.ps1"'" -AlertId '$Data/Context/DataItem/AlertId$' -SmtpHost 'smtp.company.com' -Sender 'ScomAccount@company.com' -Recipients @('Administrator;admin@company.com','User;user@company.com')

        Startup folder for the command line
        C:\Scripts
        #
        # Replace C:\Scripts with whatever folder you have copied this script into
        #

        Notification Account
        --------------------
        Make sure the notification account can get data from ops

        Logging
        -------
        For logging set $mDebug to $true, then the script will send data to the Windows PowerShell log

        ResolutionState
        ---------------
        By default this script will set the ResolutionState of the alert to Acknowledged, for a different state
        use one of the values from the list below.

        New                     : 0
        Awaiting Evidence       : 247
        Assigned to Engineering : 248
        Acknowledged            : 249
        Scheduled               : 250
        Resolved                : 254
        Closed                  : 255
    .LINK
        https://gist.github.com/jeffpatton1971/442b9a7ffe9d15ab463f
    .LINK
        http://blogs.technet.com/b/cliveeastwood/archive/2008/04/16/some-more-command-notification-tricks-and-tips.aspx
    .LINK
        http://www.microsoft.com/en-us/download/details.aspx?id=43708
#>
[CmdletBinding()]
Param
    (
    $AlertID,
    $SmtpHost,
    $SmtpPort = "25",
    $Sender,
    $mDebug = $true,
    $Recipients
    )
Begin
{
    $ScriptName = $MyInvocation.MyCommand.ToString()
    $ScriptPath = $MyInvocation.MyCommand.Path
    $Username = $env:USERDOMAIN + "\" + $env:USERNAME
    
    $ResolutionState = 249
    try
    {
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager.Common") | Out-Null
        [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.EnterpriseManagement.OperationsManager") | Out-Null

        $ScriptId = [System.Guid]::NewGuid()

        New-EventLog -Source $ScriptName -LogName 'Windows Powershell' -ErrorAction SilentlyContinue
 
        $Message = "ScriptId : $($ScriptId.Guid)`r`nScript: " + $ScriptPath + "`nScript User: " + $Username + "`nStarted: " + (Get-Date).toString()
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message

        $MGConnSetting = New-Object Microsoft.EnterpriseManagement.ManagementGroupConnectionSettings($Env:COMPUTERNAME)
        $ManagementGroup = New-Object Microsoft.EnterpriseManagement.ManagementGroup($MGConnSetting)

        $AlertSearchCriteria = "Id = `'$AlertID`'"
        $AlertCriteria = New-object Microsoft.EnterpriseManagement.Monitoring.MonitoringAlertCriteria($AlertSearchCriteria)
        #
        # ResolutionState -eq 0 means only retreive new alerts
        #
        $Alert = $ManagementGroup.GetMonitoringAlerts($AlertCriteria) |Where-Object -Property ResolutionState -eq 0

        if ($mDebug)
        {
            
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nAlertID : $($AlertID)"
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nSmtpHost : $($SmtpHost)"
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nSmtpPort : $($SmtpPort)"
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nSender : $($Sender)"
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nRecipients : $([string]::Join(",",$Recipients))"
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nMGConnSetting : $($MGConnSetting)"
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nManagementGroup : $($ManagementGroup)"
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nAlertSearchCriteria : $($AlertSearchCriteria)"
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nAlertCriteria : $($AlertCriteria)"
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nAlert : $($Alert)"
            }
        }
    catch
    {
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message "ScriptId : $($ScriptId.Guid)`r`n$($Error[0].Exception)"
        if ($Error[0].Exception.Line)
        {
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "101" -EntryType "Error" -Message "ScriptId : $($ScriptId.Guid)`r`n$($Error[0].Exception.Line.ToString())"
            }
        }
    }
Process
{
    if ($Alert)
    {
        [xml]$Context = $Alert.Context
        if ($mDebug)
        {
            Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nContext : $($Context.InnerXml)"
            }
        switch ($Alert.Name)
        {
            "Message Center"
            {
                $ContextDetails = New-Object -TypeName PSObject
                foreach ($Property in $Context.DataItem.Property)
                {
                    $Name = $Property.Name;
                    $Description = $Property."#text"
                    Add-Member -MemberType NoteProperty -Name $Name -Value $Description -InputObject $ContextDetails
                    }
                $Title = [System.Web.HttpUtility]::UrlEncode($ContextDetails.Title)
                $Title = [System.Web.HttpUtility]::UrlDecode($Title.Replace('%0a',''))

                $Published = $ContextDetails.Published
                $Expires = $ContextDetails.Expires
                $LastUpdated = $ContextDetails.LastUpdated

                $string = "%0a"
                $Array = ($EncodeDetails.Replace($string,'||')).Split('||')
                $Details = foreach ($item in $Array){if ($item){[System.Web.HttpUtility]::UrlDecode($item)}}
                #$Details = $ContextDetails.Details

                $AdditionalInformation = $ContextDetails.'Additional Information'
                $ViewInOffice = $ContextDetails.'View this message in Office 365 Message Center'

                $Subject = "Office 365 $($Alert.Name): $($Title)"
                $Body = @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<body>
<table>
<tr>
	<td>Published</td>
	<td>&nbsp;</td>
	<td>$($Published)</td>
</tr>
	<td>Expires</td>
	<td>&nbsp;</td>
	<td>$($Expires)</td>
</tr>
	<td>LastUpdated</td>
	<td>&nbsp;</td>
	<td>$($LastUpdated)</td>
</tr>
</table>
<hr />
<p>Details</p>
$($Details |ForEach-Object {"<p>$($_)</p>"})
<hr />

<p>Additional Information</p>
<a href="$($AdditionalInformation)">$($AdditionalInformation)</a>
<br />
<p>View this message in Office 365 Message Center</p>
<a href="$($ViewInOffice)">$($ViewInOffice)</a>
</body>
</html>
"@
                if ($mDebug)
                {
                    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nTitle : $($Title)"
                    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nPublished : $($Published)"
                    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nExpires : $($Expires)"
                    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nLastUpdated : $($LastUpdated)"
                    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nDetails : $($Details)"
                    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nAdditionalInformation : $($AdditionalInformation)"
                    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nViewInOffice : $($ViewInOffice)"
                    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nSubject : $($Subject)"
                    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nBody : $($Body)"
                    }
                 }
            "Office 365 Incident"
            {
                $ContextDetails = New-Object -TypeName PSObject
                foreach ($Property in $Context.DataItem.Property)
                {
                    $Name = $Property.Name;
                    $Description = $Property."#text"
                    Add-Member -MemberType NoteProperty -Name $Name -Value $Description -InputObject $ContextDetails
                    }
                $Title = [System.Web.HttpUtility]::UrlEncode($ContextDetails.Title)
                $Title = [System.Web.HttpUtility]::UrlDecode($Title.Replace('%0a',''))
                $Published = $ContextDetails.Published
                $Expires = $ContextDetails.Expires
                $LastUpdated = $ContextDetails.LastUpdated
                $ServiceFeaturesAffected = $ContextDetails.ServiceFeaturesAffected

                $string = "%0a"
                $Array = ($EncodeDetails.Replace($string,'||')).Split('||')
                $Details = foreach ($item in $Array){if ($item){[System.Web.HttpUtility]::UrlDecode($item)}}
                #$Details = $ContextDetails.Details

                $ViewInOffice = $ContextDetails.'View this incident in Office 365 service health dashboard'
                $Subject = "$($Alert.Name): $($ContextDetails.IncidentState): $($Title)"
                $Body = @"
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<body>
<table>
<tr>
	<td>Published</td>
	<td>&nbsp;</td>
	<td>$($Published)</td>
</tr>
	<td>Expires</td>
	<td>&nbsp;</td>
	<td>$($Expires)</td>
</tr>
	<td>LastUpdated</td>
	<td>&nbsp;</td>
	<td>$($LastUpdated)</td>
</tr>
</table>
<hr />
<p>Service Features Affected</p>
<p>$($ServiceFeaturesAffected)</p>
<hr />
<p>Details</p>
$($Details |ForEach-Object {"<p>$($_)</p>"})
<hr />

<p>View this incident in Office 365 service health dashboard</p>
<a href="$($ViewInOffice)">$($ViewInOffice)</a>
</body>
</html>
"@
                if ($mDebug)
                {
                    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nTitle : $($Title)"
                    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nPublished : $($Published)"
                    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nExpires : $($Expires)"
                    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nLastUpdated : $($LastUpdated)"
                    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nDetails : $($Details)"
                    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nServiceFeaturesAffected : $($ServiceFeaturesAffected)"
                    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nViewInOffice : $($ViewInOffice)"
                    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nSubject : $($Subject)"
                    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nBody : $($Body)"
                    }
                }
            }
        $MailMessage = New-Object System.Net.Mail.MailMessage
        $MailMessage.IsBodyHtml = $true
        $SMTPClient = New-Object System.Net.Mail.smtpClient
        $SMTPClient.Host = $SmtpHost
        $SMTPClient.Port = $SmtpPort
        $SMTPClient.UseDefaultCredentials = $false
        $MailMessage.Sender = $Sender
        $MailMessage.From = $Sender
        $MailMessage.Subject = $Subject

        foreach ($Recipient in $Recipients)
        {
            $Name = $Recipient.Split(";")[0]
            $Email = $Recipient.Split(";")[1]
            $MailMessage.To.Add((New-Object System.Net.Mail.MailAddress($Email, $Name)))
            if ($mDebug)
            {
                Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nRecipient : $($Recipient)"
                }
            }
        $MailMessage.Body = $Body
        $SMTPClient.Send($MailMessage)

        $Alert.ResolutionState = $ResolutionState
        $Alert.Update("")
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message "ScriptId : $($ScriptId.Guid)`r`nSet ResolutionState to : $($ResolutionState)"
        }
    else
    {
        $Message = "ScriptId : $($ScriptId.Guid)`r`nNo Alerts Found"
        Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
        }
    }
End
{
    $Message = "ScriptId : $($ScriptId.Guid)`r`nScript: " + $ScriptPath + "`nScript User: " + $Username + "`nFinished: " + (Get-Date).toString()
    Write-EventLog -LogName 'Windows Powershell' -Source $ScriptName -EventID "104" -EntryType "Information" -Message $Message
    }