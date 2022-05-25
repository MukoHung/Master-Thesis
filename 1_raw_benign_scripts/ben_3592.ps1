#Requires -Module PSSQLite
param(
    [Alias('Name', '')]
    [string]
    $ProfileName
)
<#
Updated for 9/2 patch
Updated by request of Truth91
#>
<#
For the game SCUM. This sets stats too 5 and skills to 4 for specified character.
Singleplayer only and run when the game isn't running
Requirements:
Install the module PSSQLite
Copy the line below and run it in powershell
 Install-Module -Name "PSSQLite" -Scope CurrentUser
Then run this script from powershell. Replace ThisProfileName with your character in single player
.\scum_sqlite.ps1 -ProfileName 'ThisProfileName'
or if you want to update all profiles just run the following
.\scum_sqlite.ps1
#>

$Skill_Level = 4
$Attributes = 5
$Experience_Points = 10000000

$sqlsplat = @{
    Datasource = "C:\Users\$($env:USERNAME)\AppData\Local\SCUM\Saved\SaveFiles\SCUM.db"
}
# Get all profiles from SQLite database file
$userprofiles = Invoke-SqliteQuery @sqlsplat -Query "select * from user_profile"
if ($ProfileName) {
    # Get the prisoner_id from the database
    $prisoner_id = ($userprofiles | Where-Object { $_.name -eq $ProfileName }).prisoner_id
}
else {
    # Get each prisoner_id from the database and create an array of those id's
    $prisoner_id = $userprofiles.prisoner_id
}

# Loop through each id, or only one if a profile name was provided
$prisoner_id | ForEach-Object {
    $This_prisoner_id = $_
    # Get the row of data where the id matches $This_prisoner_id
    $prisoner = Invoke-SqliteQuery @sqlsplat -Query "select * from prisoner where id = $This_prisoner_id"
    # Remove the null characters from the xml column as it messes with processing of the xml
    [xml]$prisoner_xml = $prisoner.xml -replace "`0", ''
    # Set the attribues to 5 as a string
    $prisoner_xml.Prisoner.LifeComponent.CharacterAttributes._strength = "$Attributes"
    $prisoner_xml.Prisoner.LifeComponent.CharacterAttributes._constitution = "$Attributes"
    $prisoner_xml.Prisoner.LifeComponent.CharacterAttributes._intelligence = "$Attributes"
    $prisoner_xml.Prisoner.LifeComponent.CharacterAttributes._dexterity = "$Attributes"
    # Set the attribues' history to 5 as a strings, I don't know if this affects how thing calulate. This is just in case it does.
    $prisoner_xml.Prisoner.LifeComponent.AttributeHistoryStrength.Attribute | ForEach-Object { $_._value = "$Attributes" }
    $prisoner_xml.Prisoner.LifeComponent.AttributeHistoryConstitution.Attribute | ForEach-Object { $_._value = "$Attributes" }
    $prisoner_xml.Prisoner.LifeComponent.AttributeHistoryDexterity.Attribute | ForEach-Object { $_._value = "$Attributes" }
    $prisoner_xml.Prisoner.LifeComponent.AttributeHistoryIntelligence.Attribute | ForEach-Object { $_._value = "$Attributes" }
    # Update the row in the database with the changes we made
    $prisoner = Invoke-SqliteQuery @sqlsplat -Query "update prisoner set xml = '$($prisoner_xml.OuterXml)' where id = $This_prisoner_id;"

    # Get the skills associated with $This_prisoner_id
    $prisoner_skill = Invoke-SqliteQuery @sqlsplat -Query "select * from prisoner_skill where prisoner_id = $This_prisoner_id"
    # Loop through each skill
    $prisoner_skill | Where-Object { $_.level -ne "$Skill_Level" } | ForEach-Object {
        # Remove the null characters from the xml column as it messes with processing of the xml
        [xml]$prisoner_skill_xml = $_.xml -replace "`0", ''
        # Set the _level to the $Skill_Level variable
        $prisoner_skill_xml.Skill._level = "$Skill_Level"
        # Set the _experiencePoints to $Experience_Points
        $prisoner_skill_xml.Skill._experiencePoints = "$Experience_Points"
        # Build the where part of the SQL query
        $sqlwhere = "where prisoner_id = $This_prisoner_id and name = '$($prisoner_skill_xml.Skill.'#text')'"
        # Build the rest of the SQL query
        $Query = "update prisoner_skill set level = $Skill_Level, experience = '$Experience_Points', xml = '$($prisoner_skill_xml.OuterXml)' $sqlwhere;"
        try {
            # Update the prisoner's skills
            Invoke-SqliteQuery @sqlsplat -Query $Query
        }
        catch {
            # Something broke!
            throw "error"
        }
    }
}