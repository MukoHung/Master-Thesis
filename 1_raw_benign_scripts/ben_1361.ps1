# A few handy tricks I use on a daily basis, from various sources


# Running with UAC and already elevated?  No prompts if you call things from here : )
    New-Alias -name hyperv -Value  "$env:windir\system32\virtmgmt.msc"
    New-Alias -name vsphere -value "C:\Program Files (x86)\VMware\Infrastructure\Virtual Infrastructure Client\Launcher\VpxClient.exe"
    New-Alias -Name n -Value "C:\Tools\NotePad2\notepad2.exe"
    New-Alias -name RSAT -Value "C:\Tools\Custom.msc"
    #...


# Quickly build arrays
    echo computer1 computer2 computer3
    1..10 | %{"Computer$_"}
    1..100 | %{"Computer{0:D3}" -f $_}


# Not familiar with vim, emacs, sublime, etc?  Use PowerShell to Quickly build up text!
    ( 1..100 | %{"`"Computer{0:D3}`"" -f $_} ) -join ", "
    gci C:\temp | select -ExpandProperty fullname | %{"`"$_`","}
    1..100 | %{"'Computer{0:D3}'," -f $_}


# Quickly build up an array of IP addresses
    #http://powershell.com/cs/media/p/9437.aspx
    New-IPRange -Start 192.168.0.1 -End 192.168.2.50 -Exclude 0,1,255

    <# Exclude via a few modifications
        #In the param block
        [int[]]$Exclude = @( 0, 1, 255 )
        #.....

        # instead of just joining the IP on '.', check if it's in the exclusion array
        if($Exclude -notcontains $ip[3])
        {
            $ip -join '.'
        }
    #>


# Work with parameterized SQL queries? Don't hard code the queries...
    $SQLParameters = @{
        ComputerName = 'Server1'
        SomeColumn = "SomeValue"
        SomeColumn2 = 5
        #...
    }

    $query = "UPDATE [Database].[dbo].[Table] SET $( $( foreach($key in $SQLParameters.keys){ "$key = @$key" } ) -join ", "  )"
    $query = "INSERT INTO [Database].[dbo].[Table] ($($SQLParameters.keys -join ", ")) VALUES ($( $( foreach($key in $SQLParameters.keys){ "@$key" } ) -join ", "  ))"

    #https://raw.githubusercontent.com/RamblingCookieMonster/PowerShell/master/Invoke-Sqlcmd2.ps1
    Invoke-Sqlcmd2 -ServerInstance SomeServer -Database Database -Query $query -SqlParameters $SQLParameters


# Regularly need alternate credentials, and no password management system with an API?  Use the DPAPI
    #http://poshcode.org/501
    #Keep in mind this is restricted to the account running this command, on the computer where PowerShell executed the command
    
    #One time - export any credentials you regularly need
    Expore-PSCredential -Credential $SomeESXCredentials -Path \\Some\Secure$\ESXCreds.xml
    
    #Any time you need them, or in you profile, load up the creds
    $CredESX = Import-PSCredential -Path \\Some\Secure$\ESXCreds.xml


# What was the code in that Function again?
    #http://gallery.technet.microsoft.com/scriptcenter/Open-defined-functions-in-22788d0f
    Open-ISEFunction Invoke-Sqlcmd2, Open-ISEFunction


