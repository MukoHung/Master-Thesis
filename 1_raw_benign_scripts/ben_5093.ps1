# Control Panel
[string]$app_token = 'ey...' # add the admin app token here (you need to logon to the console to get this)
[string]$pwu_license = '<License></License>' # add the license string here
[string]$server = 'localhost'
[int]$port_http = 5000
[int]$port_https = 5001
[string]$connect_method = 'http'
[string]$script_path = [System.IO.Path]::GetDirectoryName($myInvocation.MyCommand.Definition)
[string]$item_path_scripts = ($script_path + '\scripts')
[boolean]$check_http = $true
[boolean]$check_https = $false
[boolean]$install_license_if_needed = $true
[boolean]$include_endpoints_in_publishing = $true
[boolean]$publish_tags = $true
[string]$server_http = "http://${server}:${port_http}"
[string]$server_https = "https://${server}:${port_https}"
[string]$app_token_regex = '^[A-Z0-9.-]{2,}$'
[string]$pwu_license_regex = '<License><Terms>[0-9/A-Z+=]{1,}</Terms><Signature>{1}[0-9/A-Z+=]{1,}</Signature></License>'
[array]$required_modules = @( [PSCustomObject]@{ 'required_module' = 'Universal'; 'required_command' = 'Connect-UAServer'; }, [PSCustomObject]@{ 'required_module' = 'UniversalDashboard'; 'required_command' = 'Get-UDElement'; })
[array]$preset_colors = @( 'red', 'orange', 'volcano', 'gold', 'yellow', 'lime', 'green', 'cyan', 'blue', 'geekblue', 'purple', 'magenta', 'grey', 'white', 'black', 'transparent' )
[string]$tag_color_regex = '(?i)^((red)|(orange)|(volcano)|(gold)|(yellow)|(lime)|(green)|(cyan)|(blue)|(geekblue)|(purple)|(magenta)|(grey)|(white)|(black)|(transparent))|(#[0-9A-F]{6})$'

#region Functions (prerequisites)

Function Confirm-Module {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$required_module
    )
    [string]$required_module_name = $required_module.required_module
    [string]$required_module_command = $required_module.required_command
    [System.Management.Automation.CommandInfo]$command_info = Get-Command -Name $required_module_command -EA 0
    If ( $null -eq $command_info) {
        Import-Module -Name $required_module_name -EA 0
    }
    [System.Management.Automation.CommandInfo]$command_info = Get-Command -Name $required_module_command -EA 0
    If ( $null -eq $command_info) {
        Write-Host "Error: Cannot load [$required_module]. Exiting."
        Exit
    }
    [System.Management.Automation.PSModuleInfo]$module_info = Get-Module -Name $required_module_name -ListAvailable | Select-Object -First 1
    [string]$module_name = $module_info.Name
    [string]$module_version = $module_info.Version
    Write-Host "Loaded module [$module_name] version [$module_version]"
}

Function Confirm-Modules {
    Param(
        [Parameter(Mandatory = $true)]
        [array]$required_modules
    )
    $required_modules | ForEach-Object { Confirm-Module -required_module $_ }
}

Function Confirm-PWU-Server-Availability {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$server,
        [Parameter(Mandatory = $true)]
        [int32]$port_http,
        [Parameter(Mandatory = $true)]
        [int32]$port_https
    )
    $ProgressPreference = 'SilentlyContinue'
    If (($check_http -ne $true) -and ($check_https -ne $true)) {
        Write-Host "Error: You have to check at least one or the other (http or https). Please adjust the configuration and try again."
        Exit
    }    
    If ( $check_http -eq $true) {
        [boolean]$result_http = Test-NetConnection -ComputerName $server -Port $port_http -InformationLevel:Quiet
        If ( $result_http -eq $true) {
            Write-Host ""
            Write-Host "[$server] online with http protocol on port [$port_http]" -ForegroundColor Green
        }
        Else {
            Write-Host ""
            Write-Host "[$server] not online with http protocol on port [$port_http]" -ForegroundColor Red
        }
    }
    If ( $check_https -eq $true) {
        [boolean]$result_https = Test-NetConnection -ComputerName $server -Port $port_https  -InformationLevel:Quiet
        If ( $result_https -eq $true) {
            Write-Host ""
            Write-Host "[$server] online with https protocol on port [$port_https]" -ForegroundColor Green
        }
        Else {
            Write-Host ""
            Write-Host "[$server] not online with https protocol on port [$port_https]" -ForegroundColor Red
        }    
    }
    If (($result_http -ne $true) -and ($result_https -ne $true)) {
        Write-Host ""
        Write-Host "Error: Neither http or https server [$server] is online. Exiting."
        Exit
    }
    $ProgressPreference = 'Continue'
}

Function Confirm-Prerequisites {
    Confirm-Modules -required_modules $required_modules
    Confirm-PWU-Server-Availability -server $server -port_http $port_http -port_https $port_https
}

#endregion

#region Functions (Server connection)

Function Get-PSUServerVersion {
    [OutputType([string])]
    [string]$server_version_url = ($server_url + '/api/v1/Version')
    $Error.Clear()
    Try
    {
        [Microsoft.PowerShell.Commands.WebResponseObject]$response = Invoke-WebRequest -UseBasicParsing -Uri $server_version_url
    }
    Catch
    {
        [array]$error_clone = $Error.Clone()
        [string]$error_message = $error_clone | Where-Object { $null -ne $_.Exception } | Select-Object -First 1 | Select-Object -ExpandProperty Exception
        Write-Host "Error: Invoke-WebRequest failed due to [$error_message]"
        Exit
    }
    If ( $response.StatusCode -isnot [int]) {
        Write-Host "Error: Failed to get status code (integer) from $server_version_url. Please look into it and try again."
        Exit
    }
    [int]$response_code = $response.StatusCode
    [string]$response_desc = $response.Description
    [string]$response_content = $response.Content
    If ( $response_code -ne 200) {
        Write-Host "Error: Somehow the response was '$response_code $response_desc' instead of '200 OK'. Please look into this."
        Exit
    }
    Return $response_content
}

Function New-PSUServerURL {
    [OutputType([string])]
    [Cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('http', 'https')]
        [string]$connect_method
    )
    [string]$server_url = Switch ($connect_method) {
        'http' { $server_http; Break; }
        'https' { $server_https; Break; }
    }
    Return $server_url
}

Function Connect-PSUInstance {
    [Cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [string]$app_token
    )
    If ( $app_token -notmatch $app_token_regex) {
        Write-Host "Error: The app token does not conform to the app token RegEx filter. Please look into this."
        Exit
    }
    $Error.Clear()
    Try
    {
        Connect-UAServer -ComputerName $server_url -AppToken $app_token
    }
    Catch
    {
        [array]$error_clone = $Error.Clone()
        [string]$error_message = $error_clone | Where-Object { $null -ne $_.Exception } | Select-Object -First 1 | Select-Object -ExpandProperty Exception
        Write-Host "Error: Connect-UAServer failed due to [$error_message]"
        Exit
    }
    Try
    {
        [PowerShellUniversal.AppToken]$current_token_object = Get-PSUAppToken | Where-Object { $_.Token -eq $app_token } | Select-Object -First 1
    }
    Catch
    {
        [array]$error_clone = $Error.Clone()
        [string]$error_message = $error_clone | Where-Object { $null -ne $_.Exception } | Select-Object -First 1 | Select-Object -ExpandProperty Exception
        Write-Host "Error: Get-PSUAppToken failed due to [$error_message]"
        Exit
    }
    [int]$current_token_object_count = $current_token_object.Count
    If ( $current_token_object_count -eq 0) {
        Write-Host "Error: Unable to retrieve any tokens. Please look into this."
        Exit
    }
    $Error.Clear()
    Try
    {
        [PowerShellUniversal.Identity]$identity = $current_token_object.Identity
    }
    Catch
    {
        [array]$error_clone = $Error.Clone()
        [string]$error_message = $error_clone | Where-Object { $null -ne $_.Exception } | Select-Object -First 1 | Select-Object -ExpandProperty Exception
        Write-Host "Error: Unable to extract the Identity property from the app token due to [$error_message]"
        Exit
    }
    [int32]$user_id = $identity.Id
    [string]$user_name = $identity.Name
    [string]$server_version = Get-PSUServerVersion -server_url $server_url
    Write-Host "Logged in as '$user_name' (ID: $user_id) to PSU instance version [$server_version] running on [$server_url]"
}

#endregion

#region Functions (Licenses)
Function Install-PSU-License {
    [CmdletBinding()]
    Param(

    )
    If ( $pwu_license -notmatch $pwu_license_regex) {
        Write-Host "Error: Somehow the license does not match the license RegEx. Please look into this. Exiting."
        Exit
    }
    Write-Host "Attempting to install license..."
    $Error.Clear()
    Try
    {
        [System.Collections.Generic.List`1[PowerShellUniversal.License]]$license = Set-UALicense -Key $pwu_license
    }
    Catch
    {
        [array]$error_clone = $Error.Clone()
        [string]$error_message = $error_clone | Where-Object { $null -ne $_.Exception } | Select-Object -First 1 | Select-Object -ExpandProperty Exception
        Write-Host "Error: Set-UALicense failed due to [$error_message]"
        Exit
    }
    [int32]$license_count = $license.Count
    If ( $license_count -eq 0) {
        Write-Host "Error: There were will no licenses detected after attempting to install one. Please look into this."
        Exit
    }
    Return $license
}

Function Confirm-PSULicense {
    [System.Collections.Generic.List`1[PowerShellUniversal.License]]$license = Get-UALicense
    [int32]$license_count = $license.Count
    If ( $license_count -eq 0) {
        Write-Host "This PSU instance is unlicensed..."
        If ( $install_license_if_needed -eq $true) {
            Write-Host "...attempting to install a license"
            [System.Collections.Generic.List`1[PowerShellUniversal.License]]$license = Install-PSU-License
        }
        Else {
            Write-Host "...and that's just how we like it"
            Return
        }
    }
    [string]$license_clone = $license | ConvertTo-Json | ConvertFrom-Json | Select-Object Id, Licensee, StartDate, EndDate, Seats, Product, Status, Developer | ConvertTo-Json -Compress
    Write-Host "Confirmed license: $license_clone"    
}

#endregion

#region Function (Publishing tags, scripts & endpoints)

Function Publish-Tag {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$tag
    )
    [string]$tag_name = $tag.Name
    [string]$tag_color = $tag.Color
    [string]$tag_description = $tag.Description
    [hashtable]$parameters = @{}
    $parameters.Add('Name', $tag_name)
    $parameters.Add('Color', $tag_color)
    $parameters.Add('Description', $tag_description)
    $Error.Clear()
    Try
    {
        [PowerShellUniversal.Tag]$new_tag = New-PSUTag @parameters
    }
    Catch
    {
        [array]$error_clone = $Error.Clone()
        [string]$error_message = $error_clone | Where-Object { $null -ne $_.Exception } | Select-Object -First 1 | Select-Object -ExpandProperty Exception
        Write-Host "Error: New-PSUTag failed due to [$error_message]"
        Exit
    }
    If ( $new_tag.Id -isnot [int64]) {
        Write-Host "Error: Somehow New-PSUTag did not return a newly created tab object. Please look into this. Exiting."
        Exit
    }
    [string]$tag_properties = $new_tag | ConvertTo-Json -Compress
    Write-Host "Added tag: $tag_properties"
}

Function Publish-Tags {
    Param(
        [Parameter(Mandatory = $true)]
        [array]$preset_colors
    )
    If ( $publish_tags -ne $true) {
        Return
    }
    [array]$existing_tags = Get-PSUTag
    [array]$existing_tag_names = $existing_tags.Name
    [int]$existing_tags_count = $existing_tags.Count
    If ( $existing_tags_count -gt 0) {
        Write-Host "Warning: [$existing_tags_count] tags aleady exist in this instance."
    }
    [int]$preset_colors_count = $preset_colors.Count
    If ( $preset_colors_count -eq 0) {
        Write-Host "Skipping tag creation because the predefined colors array was not configured"
    }
    Else {        
        For ($i = 1; $i -le $preset_colors_count; $i++ ) {
            [string]$tag_id_display = "{0:00}" -f $i
            [string]$tag_name = "Test-$tag_id_display"
            [string]$tag_color = $preset_colors[$i - 1]
            If( $tag_color -notmatch $tag_color_regex)
            {
                Write-Host "Error: [$tag_color] does not match a known default color. Please fix this."
                Exit
            }
            [PSCustomObject]$tag = [PSCustomObject]@{ Name = "$tag_name"; Color = "$tag_color"; Description = "$tag_color"; }
            If ( $tag_name -in ($existing_tag_names)) {
                Write-Host "Warning: The tag [$tag_name] already exists. Skipping this one..."
            }
            Else {
                Publish-Tag -tag $tag
            }        
        }
    }
}

Function Publish-Script {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [System.IO.FileSystemInfo]$script_file,
        [Parameter(Mandatory = $false)]
        [switch]$script_only,
        [Parameter(Mandatory = $false)]
        [switch]$endpoint_only
    )
    If (($script_only -eq $true) -and ($endpoint_only -eq $true)) {
        Write-Host "Error: You can't use Publish-Script with both -script_only and -endpoint_only together. Please fix this."
        Exit
    }
    [string]$script_name = $script_file.BaseName
    [string]$script_fullpath = $script_file.FullName
    $Error.Clear()
    Try
    {
        [array]$script_content = Get-Content -Path "$script_fullpath"
    }
    Catch
    {
        [array]$error_clone = $Error.Clone()
        [string]$error_message = $error_clone | Where-Object { $null -ne $_.Exception } | Select-Object -First 1 | Select-Object -ExpandProperty Exception
        Write-Host "Error: Get-Content failed due to [$error_message]"
        Exit
    }
    [string]$script_content_string = $script_content -join "`r`n"
    $Error.Clear()
    Try
    {
        [scriptblock]$script_block = [scriptblock]::Create(($script_content_string))
    }
    Catch
    {
        [array]$error_clone = $Error.Clone()
        [string]$error_message = $error_clone | Where-Object { $null -ne $_.Exception } | Select-Object -First 1 | Select-Object -ExpandProperty Exception
        Write-Host "Error: Creating a script block object failed due to [$error_message]"
        Exit
    }
    If ( $endpoint_only -ne $true) {
        [hashtable]$parameters = @{}
        $parameters.Add('Name', $script_name)
        $parameters.Add('ScriptBlock', $script_block)
        $Error.Clear()
        Try
        {
            [PowerShellUniversal.Script]$script_object = New-PSUScript @parameters
        }
        Catch
        {
            [array]$error_clone = $Error.Clone()
            [string]$error_message = $error_clone | Where-Object { $null -ne $_.Exception } | Select-Object -First 1 | Select-Object -ExpandProperty Exception
            Write-Host "Error: New-PSUScript failed due to [$error_message]"
            Exit
        }
        [string]$script_file_name = $script_object.Name
        [int]$script_file_name_length = $script_file_name.Length
        If ( $script_file_name_length -eq 0) {
            Write-Host "Error: Somehow the returned script object for [$script_name] does not have a path(?) Please look into this."
            Exit
        }
        [datetime]$script_created_time = $script_object.CreatedTime
        [string]$script_created_time_display = Get-Date -Date $script_created_time -Format 'yyyy-MM-dd HH:mm:ss'
        Write-Host "Published script [$script_name] as [$script_file_name] at $script_created_time_display]"
    }
    If (($script_only -ne $true) -and ($include_endpoints_in_publishing -eq $true)) {
        [hashtable]$parameters = @{}
        $parameters.Add('Url', ('/' + $script_name))
        $parameters.Add('Endpoint', $script_block)
        $parameters.Add('Method', 'GET')
        $Error.Clear()
        Try
        {
            [PowerShellUniversal.Endpoint]$endpoint_object = New-PSUEndpoint @parameters
        }
        Catch
        {
            [array]$error_clone = $Error.Clone()
            [string]$error_message = $error_clone | Where-Object { $null -ne $_.Exception } | Select-Object -First 1 | Select-Object -ExpandProperty Exception
            Write-Host "Error: New-PSUEndpoint failed due to [$error_message]"
            Exit
        }        
        [string]$endpoint_url = $endpoint_object.Url
        [int]$endpoint_url_length = $endpoint_url.Length
        If ( $endpoint_url_length -eq 0) {
            Write-Host "Error: Somehow the returned endpoint object for [$script_name] does not have a URL(?) Please look into this."
            Exit
        }
        Write-Host "Published endpoint [$script_name] as [$endpoint_url]"        
    }
}

Function Publish-Scripts {
    [boolean]$scripts_path_exists = Test-Path -Path $item_path_scripts
    If ( $scripts_path_exists -eq $false) {
        Write-Host "Warning: The Scripts path does not exist? Skipping this..." -ForegroundColor Yellow
        Return
    }
    [array]$existing_scripts = Get-PSUScript
    [int]$existing_scripts_count = $existing_scripts.Count
    If ( $existing_scripts_count -gt 0) {
        [array]$existing_scripts = $existing_scripts -replace '.ps1'
    }
    [array]$existing_endpoints = Get-PSUEndpoint
    [int]$existing_endpoints_count = $existing_endpoints.Count
    If ( $existing_endpoints_count -gt 0) {
        [array]$existing_endpoints = $existing_endpoints.Url -replace '/'
    }    
    If (($existing_scripts_count -gt 0) -or ($existing_endpoints_count -gt 0)) {
        Write-Host "Warning: [$existing_scripts_count] scripts and [$existing_endpoints_count] API endpoints are already published..."
    }
    $Error.Clear()
    Try
    {
        [array]$script_files = Get-ChildItem -Path $item_path_scripts
    }
    Catch
    {
        [array]$error_clone = $Error.Clone()
        [string]$error_message = $error_clone | Where-Object { $null -ne $_.Exception } | Select-Object -First 1 | Select-Object -ExpandProperty Exception
        Write-Host "Error: Get-ChildItem failed due to [$error_message]"
        Exit
    }
    [int]$script_files_count = $script_files.Count
    If ( $script_files_count -eq 0) {
        Write-Host "Warning: Publishing scripts is enabled but there were 0 scripts available. Please look into this."
        Return
    }
    ForEach ($script_file in $script_files) {
        [string]$script_file_name = $script_file.Name -replace '.ps1'
        If (($script_file_name -in $existing_scripts) -and ($script_file_name -in $existing_endpoints)) {
            Write-Host "Warning: $script_file_name already exists on this instance (as both a script and an endpoint). Skipping this..."
        }
        ElseIf (($script_file_name -in $existing_scripts) -and ($include_endpoints_in_publishing -ne $true)) {
            Write-Host "Warning: $script_file_name already exists on this instance (as a script, endpoint is not enabled). Skipping this..."
        }
        ElseIf (($script_file_name -in $existing_scripts) -and ($script_file_name -notin $existing_endpoints) -and ($include_endpoints_in_publishing -eq $true)) {
            Write-Host "Warning: $script_file_name exists as a script but not as a endpoint. Proceeding to publish as endpoint only."
            Publish-Script -script_file $script_file -endpoint_only
        }
        ElseIf (($script_file_name -notin $existing_scripts) -and ($script_file_name -in $existing_endpoints)) {
            Write-Host "Warning: $script_file_name exists as an endpoint but not a script. Proceeding to publish as a script only."
            Publish-Script -script_file $script_file -script_only
        }
        Else {
            Publish-Script -script_file $script_file
        }
    }
}

#endregion

Confirm-Prerequisites
[string]$server_url = New-PSUServerURL -connect_method $connect_method
Connect-PSUInstance -app_token $app_token
Confirm-PSULicense
Publish-Tags -preset_colors $preset_colors
Publish-Scripts