$ErrorActionPreference = "Stop" # force stop on failure

$configFile = ".\config\settings.json"

if ((Test-Path $configFile) -eq $False) {
    Write-Output "Error: "
    Write-Output "First copy the file '.\config\settings.example.json' to '$configFile'."
    Write-Output "Next, fill in your API credentials, Signer name and email to continue."
}

# Get required environment variables from .\config\settings.json file
$config = Get-Content $configFile -Raw | ConvertFrom-Json

function checkCC {

    # Fill in Quickstart Carbon Copy config values
    if ($config.CC_EMAIL -eq "{CC_EMAIL}" ) {
        Write-Output "It looks like this is your first time running the launcher from Quickstart. "
        $config.CC_EMAIL = Read-Host "Enter a CC email address to receive copies of envelopes"
        $config.CC_NAME = Read-Host "Enter a name for your CC recipient"
        Write-Output ""
        write-output $config | ConvertTo-Json | Set-Content $configFile
    }

}

function  checkOrgId {

    if ($config.ORGANIZATION_ID -eq "{ORGANIZATION_ID}" ) {
        Write-Output "No Organization Id in the config file. Looking for one via the API"
        # Get required environment variables from .\config\settings.json file
        $accessToken = Get-Content .\config\ds_access_token.txt

        $base_path = "https://api-d.docusign.net/management"

        $response = New-TemporaryFile
        Invoke-RestMethod `
            -Uri "$base_path/v2/organizations" `
            -Method 'GET' `
            -Headers @{
            'Authorization' = "Bearer $accessToken";
            'Content-Type'  = "application/json";
        } `
            -OutFile $response

        $organizationId = $(Get-Content $response | ConvertFrom-Json).organizations[0].id

        $config.ORGANIZATION_ID = $organizationId
        write-output $config | ConvertTo-Json | Set-Content $configFile
        Write-Output "Organization id has been written to config file..."
        Remove-Item $response

    }
}


function startLauncher {
    do {
        # Preparing list of Api
        Enum listApi {
            eSignature = 1;
            Rooms = 2;
            Click = 3;
            Monitor = 4;
            Admin = 5;
            Exit = 6;
        }

        $listApiView = $null;

        # Load via Quickstart
        if ($config.QUICKSTART -eq "true" ) {
            if ($null -eq $firstPassComplete) {
                Write-Output ''
                Write-Output "Quickstart Enabled, please wait"
                write-Output ''
                powershell.exe -Command .\OAuth\code_grant.ps1 -clientId $($config.INTEGRATION_KEY_AUTH_CODE) -clientSecret $($config.SECRET_KEY) -apiVersion $("eSignature")


                if ((Test-Path "./config/ds_access_token.txt") -eq $true) {
                    powershell.exe -Command .\eg001EmbeddedSigning.ps1

                    # This is to prevent getting stuck on the
                    # first example after trying it the first time
                    $firstPassComplete = "true"

                    startSignature
                }
                else {
                    Write-Error "Failed to retrieve OAuth Access token, check your settings.json and that port 8080 is not in use"  -ErrorAction Stop
                }
            }
        }
        do {
            Write-Output ''
            Write-Output 'Choose API: '
            Write-Output "$([int][listApi]::eSignature)) eSignature"
            Write-Output "$([int][listApi]::Rooms)) Rooms"
            Write-Output "$([int][listApi]::Click)) Click"
            Write-Output "$([int][listApi]::Monitor)) Monitor"
            Write-Output "$([int][listApi]::Admin)) Admin"
            Write-Output "$([int][listApi]::Exit)) Exit"
            [int]$listApiView = Read-Host "Please make a selection"
        } while (-not [listApi]::IsDefined([listApi], $listApiView));

        if ($listApiView -eq [listApi]::eSignature) {
            startAuth "eSignature"
        }
        elseif ($listApiView -eq [listApi]::Rooms) {
            startAuth "rooms"
        }
        elseif ($listApiView -eq [listApi]::Click) {
            startAuth "click"
        }
        elseif ($listApiView -eq [listApi]::Monitor) {
            startAuth "monitor"
        }
        elseif ($listApiView -eq [listApi]::Admin) {
            startAuth "admin"
        }
        elseif ($listApiView -eq [listApi]::Exit) {
            exit 1
        }
    } until ($listApiView -eq [listApi]::Exit)
}

function startAuth ($apiVersion) {
    # Preparing a list of Authorization methods
    Enum AuthType {
        CodeGrant = 1;
        JWT = 2;
        Exit = 3;
    }

    $AuthTypeView = $null;
    if ($apiVersion -eq "monitor") {
        $AuthTypeView = [AuthType]::JWT; # Monitor API only supports JWT
    }
    else {
        do {
            Write-Output ""
            Write-Output 'Choose an OAuth Strategy: '
            Write-Output "$([int][AuthType]::CodeGrant)) Authorization Code Grant"
            Write-Output "$([int][AuthType]::JWT)) Json Web Token (JWT)"
            Write-Output "$([int][AuthType]::Exit)) Exit"
            [int]$AuthTypeView = Read-Host "Select an OAuth method to Authenticate with your DocuSign account"
        } while (-not [AuthType]::IsDefined([AuthType], $AuthTypeView));
    }

    if ($AuthTypeView -eq [AuthType]::Exit) {
        startLauncher
    }
    elseif ($AuthTypeView -eq [AuthType]::CodeGrant) {
        powershell.exe -Command .\OAuth\code_grant.ps1 -clientId $($config.INTEGRATION_KEY_AUTH_CODE) -clientSecret $($config.SECRET_KEY) -apiVersion $($apiVersion)
        if ((Test-Path "./config/ds_access_token.txt") -eq $false) {
            Write-Error "Failed to retrieve OAuth Access token, check your settings.json and that port 8080 is not in use"  -ErrorAction Stop
        }
    }
    elseif ($AuthTypeView -eq [AuthType]::JWT) {
        powershell.exe -Command .\OAuth\jwt.ps1 -clientId $($config.INTEGRATION_KEY_AUTH_CODE) -apiVersion $($apiVersion)
        if ((Test-Path "./config/ds_access_token.txt") -eq $false) {
            Write-Error "Failed to retrieve OAuth Access token, check your settings.json and that port 8080 is not in use"  -ErrorAction Stop
        }
    }

    if ($listApiView -eq [listApi]::eSignature) {
        startSignature
    }
    elseif ($listApiView -eq [listApi]::Rooms) {
        startRooms
    }
    elseif ($listApiView -eq [listApi]::Click) {
        startClick
    }
    elseif ($listApiView -eq [listApi]::Monitor) {
        startMonitor
    }
    elseif ($listApiView -eq [listApi]::Admin) {
        startAdmin
    }
}

function startSignature {
    do {
        # Preparing a list of eSignature examples
        Enum ApiExamples {
            Embedded_Signing = 1;
            Signing_Via_Email = 2;
            List_Envelopes = 3;
            Envelope_Info = 4;
            Envelope_Recipients = 5;
            Envelope_Docs = 6;
            Envelope_Get_Doc = 7;
            Create_Template = 8;
            Use_Template = 9;
            Send_Binary_Docs = 10;
            Embedded_Sending = 11;
            Embedded_Console = 12;
            Add_Doc_To_Template = 13;
            Collect_Payment = 14;
            Envelope_Tab_Data = 15;
            Set_Tab_Values = 16;
            Set_Template_Tab_Values = 17;
            Envelope_Custom_Field_Data = 18;
            Signing_Via_Email_With_Access_Code = 19;
            Signing_Via_Email_With_Phone_Authentication = 20;
            Signing_Via_Email_With_Knowledge_Based_Authentication = 22;
            Signing_Via_Email_With_IDV_Authentication = 23;
            Creating_Permission_Profiles = 24;
            Setting_Permission_Profiles = 25;
            Updating_Individual_Permission = 26;
            Deleting_Permissions = 27;
            Creating_A_Brand = 28;
            Applying_Brand_Envelope = 29;
            Applying_Brand_Template = 30;
            Bulk_Sending = 31;
            Pause_Signature_Workflow = 32;
            Unpause_Signature_Workflow = 33;
            Use_Conditional_Recipients = 34;
            SMS_Delivery = 35;
            Home = 36;
        }

        $ApiExamplesView = $null;
        do {
            Write-Output ""
            Write-Output 'Select the action: '
            Write-Output "$([int][ApiExamples]::Embedded_Signing)) Embedded_Signing"
            Write-Output "$([int][ApiExamples]::Signing_Via_Email)) Signing_Via_Email"
            Write-Output "$([int][ApiExamples]::List_Envelopes)) List_Envelopes"
            Write-Output "$([int][ApiExamples]::Envelope_Info)) Envelope_Info"
            Write-Output "$([int][ApiExamples]::Envelope_Recipients)) Envelope_Recipients"
            Write-Output "$([int][ApiExamples]::Envelope_Docs)) Envelope_Docs"
            Write-Output "$([int][ApiExamples]::Envelope_Get_Doc)) Envelope_Get_Doc"
            Write-Output "$([int][ApiExamples]::Create_Template)) Create_Template"
            Write-Output "$([int][ApiExamples]::Use_Template)) Use_Template"
            Write-Output "$([int][ApiExamples]::Send_Binary_Docs)) Send_Binary_Docs"
            Write-Output "$([int][ApiExamples]::Embedded_Sending)) Embedded_Sending"
            Write-Output "$([int][ApiExamples]::Embedded_Console)) Embedded_Console"
            Write-Output "$([int][ApiExamples]::Add_Doc_To_Template)) Add_Doc_To_Template"
            Write-Output "$([int][ApiExamples]::Collect_Payment)) Collect_Payment"
            Write-Output "$([int][ApiExamples]::Envelope_Tab_Data)) Envelope_Tab_Data"
            Write-Output "$([int][ApiExamples]::Set_Tab_Values)) Set_Tab_Values"
            Write-Output "$([int][ApiExamples]::Set_Template_Tab_Values)) Set_Template_Tab_Values"
            Write-Output "$([int][ApiExamples]::Envelope_Custom_Field_Data)) Envelope_Custom_Field_Data"
            Write-Output "$([int][ApiExamples]::Signing_Via_Email_With_Access_Code)) Signing_Via_Email_With_Access_Code"
            Write-Output "$([int][ApiExamples]::Signing_Via_Email_With_Phone_Authentication)) Signing_Via_Email_With_Phone_Authentication"
            Write-Output "$([int][ApiExamples]::Signing_Via_Email_With_Knowledge_Based_Authentication)) Signing_Via_Email_With_Knowledge_Based_Authentication"
            Write-Output "$([int][ApiExamples]::Signing_Via_Email_With_IDV_Authentication)) Signing_Via_Email_With_IDV_Authentication"
            Write-Output "$([int][ApiExamples]::Creating_Permission_Profiles)) Creating_Permission_Profiles"
            Write-Output "$([int][ApiExamples]::Setting_Permission_Profiles)) Setting_Permission_Profiles"
            Write-Output "$([int][ApiExamples]::Updating_Individual_Permission)) Updating_Individual_Permission"
            Write-Output "$([int][ApiExamples]::Deleting_Permissions)) Deleting_Permissions"
            Write-Output "$([int][ApiExamples]::Creating_A_Brand)) Creating_A_Brand"
            Write-Output "$([int][ApiExamples]::Applying_Brand_Envelope)) Applying_Brand_Envelope"
            Write-Output "$([int][ApiExamples]::Applying_Brand_Template)) Applying_Brand_Template"
            Write-Output "$([int][ApiExamples]::Bulk_Sending)) Bulk_Sending"
            Write-Output "$([int][ApiExamples]::Pause_Signature_Workflow)) Pause_Signature_Workflow"
            Write-Output "$([int][ApiExamples]::Unpause_Signature_Workflow)) Unpause_Signature_Workflow"
            Write-Output "$([int][ApiExamples]::Use_Conditional_Recipients)) Use_Conditional_Recipients"
            Write-Output "$([int][ApiExamples]::SMS_Delivery)) SMS_Delivery"
            Write-Output "$([int][ApiExamples]::Home)) Home"
            [int]$ApiExamplesView = Read-Host "Select the action"
        } while (-not [ApiExamples]::IsDefined([ApiExamples], $ApiExamplesView));

        if ($ApiExamplesView -eq [ApiExamples]::Embedded_Signing) {
            powershell.exe -Command .\eg001EmbeddedSigning.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Signing_Via_Email) {
            checkCC
            powershell.exe -Command .\examples\eSignature\eg002SigningViaEmail.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::List_Envelopes) {
            powershell.exe -Command .\examples\eSignature\eg003ListEnvelopes.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Envelope_Info) {
            powershell.exe -Command .\examples\eSignature\eg004EnvelopeInfo.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Envelope_Recipients) {
            powershell.exe .\examples\eSignature\eg005EnvelopeRecipients.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Envelope_Docs) {
            powershell.exe .\examples\eSignature\eg006EnvelopeDocs.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Envelope_Get_Doc) {
            powershell.exe .\examples\eSignature\eg007EnvelopeGetDoc.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Create_Template) {
            powershell.exe .\examples\eSignature\eg008CreateTemplate.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Use_Template) {
            checkCC
            powershell.exe .\examples\eSignature\eg009UseTemplate.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Send_Binary_Docs) {
            checkCC
            powershell.exe .\examples\eSignature\eg010SendBinaryDocs.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Embedded_Sending) {
            checkCC
            powershell.exe .\examples\eSignature\eg011EmbeddedSending.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Embedded_Console) {
            powershell.exe .\examples\eSignature\eg012EmbeddedConsole.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Add_Doc_To_Template) {
            checkCC
            powershell.exe .\examples\eSignature\eg013AddDocToTemplate.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Collect_Payment) {
            checkCC
            powershell.exe .\examples\eSignature\eg014CollectPayment.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Envelope_Tab_Data) {
            powershell.exe .\examples\eSignature\eg015EnvelopeTabData.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Set_Tab_Values) {
            powershell.exe .\examples\eSignature\eg016SetTabValues.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Set_Template_Tab_Values) {
            checkCC
            powershell.exe .\examples\eSignature\eg017SetTemplateTabValues.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Envelope_Custom_Field_Data) {
            powershell.exe .\examples\eSignature\eg018EnvelopeCustomFieldData.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Signing_Via_Email_With_Access_Code) {
            powershell.exe .\examples\eSignature\eg019SigningViaEmailWithAccessCode.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Signing_Via_Email_With_Phone_Authentication) {
            powershell.exe .\examples\eSignature\eg020SigningViaEmailWithPhoneAuthentication.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Signing_Via_Email_With_Knowledge_Based_Authentication) {
            powershell.exe .\examples\eSignature\eg022SigningViaEmailWithKnoweldgeBasedAuthentication.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Signing_Via_Email_With_IDV_Authentication) {
            powershell.exe .\examples\eSignature\eg023SigningViaEmailWithIDVAuthentication.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Creating_Permission_Profiles) {
            powershell.exe .\examples\eSignature\eg024CreatingPermissionProfiles.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Setting_Permission_Profiles) {
            powershell.exe .\examples\eSignature\eg025SettingPermissionProfiles.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Updating_Individual_Permission) {
            powershell.exe .\examples\eSignature\eg026UpdatingIndividualPermission.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Deleting_Permissions) {
            powershell.exe .\examples\eSignature\eg027DeletingPermissions.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Creating_A_Brand) {
            powershell.exe .\examples\eSignature\eg028CreatingABrand.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Applying_Brand_Envelope) {
            powershell.exe .\examples\eSignature\eg029ApplyingBrandEnvelope.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Applying_Brand_Template) {
            checkCC
            powershell.exe .\examples\eSignature\eg030ApplyingBrandTemplate.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Bulk_Sending) {
            checkCC
            powershell.exe .\examples\eSignature\eg031BulkSending.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Pause_Signature_Workflow) {
            checkCC
            powershell.exe .\examples\eSignature\eg032PauseSignatureWorkflow.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Unpause_Signature_Workflow) {
            powershell.exe .\examples\eSignature\eg033UnpauseSignatureWorkflow.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::Use_Conditional_Recipients) {
            checkCC
            powershell.exe .\examples\eSignature\eg034UseConditionalRecipients.ps1
        }
        elseif ($ApiExamplesView -eq [ApiExamples]::SMS_Delivery) {
            checkCC
            powershell.exe .\examples\eSignature\eg035SMSDelivery.ps1
        }
    } until ($ApiExamplesView -eq [ApiExamples]::Home)
    startLauncher
}

function startRooms {
    do {
        Enum listRoomExamples {
            CreateRoomWithDataController = 1;
            CreateRoomWithTemplateController = 2;
            ExportDataFromRoomController = 3;
            AddFormsToRoomController = 4;
            GetRoomsWithFiltersController = 5;
            CreateAnExternalFormFillSessionController = 6;
            CreateFormGroup = 7;
            AccessFormGroup = 8;
            AssignFormGroup = 9;
            Home = 10;
        }
        $listRoomExamplesView = $null;
        do {
            Write-Output ""
            Write-Output 'Select the action: '
            Write-Output "$([int][listRoomExamples]::CreateRoomWithDataController)) Create room with data controller"
            Write-Output "$([int][listRoomExamples]::CreateRoomWithTemplateController)) Create room with template controller"
            Write-Output "$([int][listRoomExamples]::ExportDataFromRoomController)) Export data from room controller"
            Write-Output "$([int][listRoomExamples]::AddFormsToRoomController)) Add forms to room controller"
            Write-Output "$([int][listRoomExamples]::GetRoomsWithFiltersController)) Get rooms with filters controller"
            Write-Output "$([int][listRoomExamples]::CreateAnExternalFormFillSessionController)) Create an external form fill session controller"
            Write-Output "$([int][listRoomExamples]::CreateFormGroup)) Create a form group"
            Write-Output "$([int][listRoomExamples]::AccessFormGroup)) Grant office access to a form group"
            Write-Output "$([int][listRoomExamples]::AssignFormGroup)) Assign a form to a form group"
            Write-Output "$([int][listRoomExamples]::Home)) Home"
            [int]$listRoomExamplesView = Read-Host "Select the action"
        } while (-not [listRoomExamples]::IsDefined([listRoomExamples], $listRoomExamplesView));

        if ($listRoomExamplesView -eq [listRoomExamples]::CreateRoomWithDataController) {
            powershell.exe -Command .\examples\Rooms\eg001CreateRoomWithDataController.ps1
        }
        elseif ($listRoomExamplesView -eq [listRoomExamples]::CreateRoomWithTemplateController) {
            powershell.exe -Command .\examples\Rooms\eg002CreateRoomWithTemplateController.ps1
        }
        elseif ($listRoomExamplesView -eq [listRoomExamples]::ExportDataFromRoomController) {
            powershell.exe -Command .\examples\Rooms\eg003ExportDataFromRoomController.ps1
        }
        elseif ($listRoomExamplesView -eq [listRoomExamples]::AddFormsToRoomController) {
            powershell.exe -Command .\examples\Rooms\eg004AddFormsToRoomController.ps1
        }
        elseif ($listRoomExamplesView -eq [listRoomExamples]::GetRoomsWithFiltersController) {
            powershell.exe -Command .\examples\Rooms\eg005GetRoomsWithFiltersController.ps1
        }
        elseif ($listRoomExamplesView -eq [listRoomExamples]::CreateAnExternalFormFillSessionController) {
            powershell.exe -Command .\examples\Rooms\eg006CreateAnExternalFormFillSessionController.ps1
        }
        elseif ($listRoomExamplesView -eq [listRoomExamples]::CreateFormGroup) {
            powershell.exe -Command .\examples\Rooms\eg007CreateFormGroup.ps1
        }
        elseif ($listRoomExamplesView -eq [listRoomExamples]::AccessFormGroup) {
            powershell.exe -Command .\examples\Rooms\eg008AccessFormGroup.ps1
        }
        elseif ($listRoomExamplesView -eq [listRoomExamples]::AssignFormGroup) {
            powershell.exe -Command .\examples\Rooms\eg009AssignFormGroup.ps1
        }
    } until ($listRoomExamplesView -eq [listRoomExamples]::Home)
    startLauncher
}

function startClick {
    do {
        Enum listClickExamples {
            createClickwrap = 1;
            activateClickwrap = 2;
            clickwrapVersioning = 3;
            retrieveClickwraps = 4;
            getClickwrapResponses = 5;
            Home = 6;
        }
        $listClickExamplesView = $null;
        do {
            Write-Output ""
            Write-Output 'Select the action: '
            Write-Output "$([int][listClickExamples]::createClickwrap)) Create clickwrap"
            Write-Output "$([int][listClickExamples]::activateClickwrap)) Activate clickwrap"
            Write-Output "$([int][listClickExamples]::clickwrapVersioning)) clickwrap Versioning"
            Write-Output "$([int][listClickExamples]::retrieveClickwraps)) Retrieve clickwraps"
            Write-Output "$([int][listClickExamples]::getClickwrapResponses)) Get clickwrap Responses"
            Write-Output "$([int][listClickExamples]::Home)) Home"
            [int]$listClickExamplesView = Read-Host "Select the action"
        } while (-not [listClickExamples]::IsDefined([listClickExamples], $listClickExamplesView));

        if ($listClickExamplesView -eq [listClickExamples]::createClickwrap) {
            powershell.exe -Command .\examples\Click\eg001CreateClickwrap.ps1
        }
        elseif ($listClickExamplesView -eq [listClickExamples]::activateClickwrap) {
            powershell.exe -Command .\examples\Click\eg002ActivateClickwrap.ps1
        }
        elseif ($listClickExamplesView -eq [listClickExamples]::clickwrapVersioning) {
            powershell.exe -Command .\examples\Click\eg003CreateNewClickwrapVersion.ps1
        }
        elseif ($listClickExamplesView -eq [listClickExamples]::retrieveClickwraps) {
            powershell.exe -Command .\examples\Click\eg004GetListOfClickwraps.ps1
        }
        elseif ($listClickExamplesView -eq [listClickExamples]::getClickwrapResponses) {
            powershell.exe -Command .\examples\Click\eg005GetClickwrapResponses.ps1
        }
    } until ($listClickExamplesView -eq [listClickExamples]::Home)
    startLauncher
}

function startMonitor {
    do {
        Enum listMonitorExamples {
            getMonitoringData = 1;
            Home = 2;
        }
        $listMonitorExamplesView = $null;
        do {
            Write-Output ""
            Write-Output 'Select the action: '
            Write-Output "$([int][listMonitorExamples]::getMonitoringData)) Get Monitoring Data"
            Write-Output "$([int][listMonitorExamples]::Home)) Home"
            [int]$listMonitorExamplesView = Read-Host "Select the action"
        } while (-not [listMonitorExamples]::IsDefined([listMonitorExamples], $listMonitorExamplesView));

        if ($listMonitorExamplesView -eq [listMonitorExamples]::getMonitoringData) {
            powershell.exe -Command .\examples\Monitor\eg001getMonitoringData.ps1
        }
    } until ($listMonitorExamplesView -eq [listMonitorExamples]::Home)
    startLauncher
}

function startAdmin {
    do {
        Enum listAdminExamples {
            createNewUserWithActiveStatus = 1;
            createActiveCLMEsignUser = 2;
            bulkExportUserData = 3;
            addUsersViaBulkImport = 4;
            auditUsers = 5
            Home = 6;
        }
        $listAdminExamplesView = $null;
        do {
            Write-Output ""
            Write-Output 'Select the action: '
            Write-Output "$([int][listAdminExamples]::createNewUserWithActiveStatus)) Create a new user with active status"
            Write-Output "$([int][listAdminExamples]::createActiveCLMEsignUser)) Create an active CLM and ESign user"
            Write-Output "$([int][listAdminExamples]::bulkExportUserData)) Bulk-export user data"
            Write-Output "$([int][listAdminExamples]::addUsersViaBulkImport)) Add users via bulk import"
            Write-Output "$([int][listAdminExamples]::auditUsers)) Audit users"
            Write-Output "$([int][listAdminExamples]::Home)) Home"
            [int]$listAdminExamplesView = Read-Host "Select the action"
        } while (-not [listAdminExamples]::IsDefined([listAdminExamples], $listAdminExamplesView));

        if ($listAdminExamplesView -eq [listAdminExamples]::createNewUserWithActiveStatus) {
            checkOrgId
            powershell.exe -Command .\examples\Admin\eg001CreateNewUserWithActiveStatus.ps1

        }
        elseif ($listAdminExamplesView -eq [listAdminExamples]::createActiveCLMEsignUser) {
            checkOrgId
            powershell.exe -Command .\examples\Admin\eg002createActiveCLMEsignUser.ps1

        }
        elseif ($listAdminExamplesView -eq [listAdminExamples]::bulkExportUserData) {
            checkOrgId
            powershell.exe -Command .\examples\Admin\eg003BulkExportUserData.ps1
        }
        elseif ($listAdminExamplesView -eq [listAdminExamples]::addUsersViaBulkImport) {
            checkOrgId
            powershell.exe -Command .\examples\Admin\eg004AddUsersViaBulkImport.ps1
        }
        elseif ($listAdminExamplesView -eq [listAdminExamples]::auditUsers) {
            checkOrgId
            powershell.exe -Command .\examples\Admin\eg005AuditUsers.ps1
        }
    } until ($listAdminExamplesView -eq [listAdminExamples]::Home)
    startLauncher
}

Write-Output "Welcome to the DocuSign PowerShell Launcher"
startLauncher