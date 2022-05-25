# |Info|
# Written by Bryan O'Connell, November 2014
# Purpose: Sample of a functional test script for a RESTful API.
#
# Thanks to contributors on the 'jsonplaceholder' project for making a publicly 
# accesible and generic REST API (which is used in the examples below).
#    - http://jsonplaceholder.typicode.com
#    - https://github.com/typicode/jsonplaceholder
#
# |Info| 

#------------------------------------------------------------------------------
# FUNCTIONS:

function CreateTimestamp
{
    $TimeInfo = New-Object System.Globalization.DateTimeFormatInfo;
    $Timestamp = Get-Date -Format $TimeInfo.SortableDateTimePattern;
    $Timestamp = $Timestamp.Replace(":", "-");

    return $Timestamp;
}

function WriteToLog
{ param([string]$TextToWrite)
    
    $TextToWrite | Out-File $LOG_FILE -Append;
}

function LogErrorMessage
{ param([string]$ResultMsg, [string]$ErrorMsg)

    WriteToLog $ResultMsg;
    WriteToLog ("Error Message - " + $ErrorMsg);
    WriteToLog ""; #whitespace
}

function RunRoute_GET
{ param([string]$ApiRoute, [int]$SecondsAllowed)

    Write-Host "Testing $ApiRoute";
    $ResponseData = New-Object PSObject;

    Try
    {
        $ResponseData = (Invoke-RestMethod -Uri $ApiRoute -Method Get -DisableKeepAlive -TimeoutSec $SecondsAllowed);
        WriteToLog ("Results for $ApiRoute - (GET) PASS");
    }
    Catch
    {
        LogErrorMessage ("Results for $ApiRoute - (GET) FAIL") $_.Exception.Message;
    }

    return $ResponseData;
}

function RunRoute_DELETE
{ param([string]$ApiRoute, [int]$SecondsAllowed)

    Write-Host "Testing $ApiRoute";
    $DeleteWasMade = $False;

    Try
    {
        Invoke-WebRequest -Uri $ApiRoute -Method Delete -DisableKeepAlive -TimeoutSec $SecondsAllowed;
        WriteToLog ("Results for $ApiRoute - (DELETE) PASS");
        $DeleteWasMade = $True;
    }
    Catch
    {
        LogErrorMessage ("Results for $ApiRoute - (DELETE) FAIL") $_.Exception.Message;
    }

    return $DeleteWasMade;
}

function RunRoute_POST
{ param([string]$ApiRoute, [object]$BodyContent, [int]$SecondsAllowed)

    Write-Host "Testing $ApiRoute";
    $ResponseData = New-Object PSObject;

    Try
    {
        $ResponseData = (Invoke-RestMethod -Uri $ApiRoute -Method Post -Body $BodyContent -ContentType $CONTENT_TYPE -DisableKeepAlive -TimeoutSec $SecondsAllowed);
        WriteToLog ("Results for $ApiRoute - (POST) PASS");
    }
    Catch
    {
        LogErrorMessage ("Results for $ApiRoute - (POST) FAIL") $_.Exception.Message;
    }

    return $ResponseData;
}

function RunRoute_PUT
{ param([string]$ApiRoute, [object]$BodyContent, [int]$SecondsAllowed)

    Write-Host "Testing $ApiRoute";
    $UpdateWasMade = $false;

    Try
    {
        Invoke-WebRequest -Uri $ApiRoute -Method Put -Body $BodyContent -ContentType $CONTENT_TYPE -DisableKeepAlive -TimeoutSec $SecondsAllowed;
        WriteToLog ("Results for $ApiRoute - (PUT) PASS");
        $UpdateWasMade = $true;
    }
    Catch
    {
        LogErrorMessage ("Results for $ApiRoute - (PUT) FAIL") $_.Exception.Message;
    }

    return $UpdateWasMade;
}

#------------------------------------------------------------------------------
# CONSTANTS:

Set-Variable TIME_STAMP (CreateTimestamp) -Option ReadOnly -Force;
Set-Variable LOG_FILE ("RestApiTest_" + ($TIME_STAMP + ".log")) -Option ReadOnly -Force;

Set-Variable BASE_URL ("http://jsonplaceholder.typicode.com") -Option ReadOnly -Force;
Set-Variable CONTENT_TYPE ("application/json") -Option ReadOnly -Force;

#------------------------------------------------------------------------------

# Timer will measure total runtime of the testing process.
$Timer = [System.Diagnostics.Stopwatch]::StartNew();

# GET examples - Get all Users, and pick a random User for further tests:
$ListOfAllUsers = RunRoute_GET -ApiRoute ($BASE_URL + "/users") -SecondsAllowed 3;
$RandomUser = $ListOfAllUsers | Get-Random;
$UserId = $RandomUser.id;
$UserRecord = RunRoute_GET -ApiRoute ($BASE_URL + "/users/" + $UserId) -SecondsAllowed 2;


#POST example - assign a new Todo to the User:
$NewToDo = @{
    "userId" = $UserId; 
    "title" = "Please delete the last Post you made; it is no longer needed."; 
    "completed" = $False;
};
$ToDoRecord = RunRoute_POST -ApiRoute ($BASE_URL + "/todos") -BodyContent (ConvertTo-Json $NewToDo) -SecondsAllowed 2;


# DELETE example - complete the ToDo that was assigned to the user by deleting their last Post:
$ListOfUserPosts = RunRoute_GET -ApiRoute ($BASE_URL + "/posts?userId=" + $UserId) -SecondsAllowed 3;
$LastPost = $ListOfUserPosts[-1];
$PostWasDeleted = RunRoute_DELETE -ApiRoute ($BASE_URL + "/posts/" + $LastPost.id) -SecondsAllowed 2;


# PUT example - User has accomplished the requested task, so let's update the 'completed' status of one of their open ToDos.
# NOTE: This API does not actually save changes, so we can't update the record we "created" in the POST example.
$ListOfIncompleteToDos = RunRoute_GET -ApiRoute ($BASE_URL + "/todos?completed=false&userId=" + $UserId) -SecondsAllowed 3;
$UpdatedToDo = $ListOfIncompleteToDos | Get-Random;
$UpdatedToDo.completed = $True;
$ToDoWasUpdated = RunRoute_PUT -ApiRoute ($BASE_URL + "/todos/" + $UpdatedToDo.id) -BodyContent (ConvertTo-Json $UpdatedToDo) -SecondsAllowed 2; 


$Timer.Stop();
$RunTime = ("Test is complete. Total run time: " + $Timer.Elapsed.ToString())
Write-Host ($RunTime);
WriteToLog $RunTime;
