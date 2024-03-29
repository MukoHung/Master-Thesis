#paths to the project templates on your system
$global:classTemplate = "D:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\ProjectTemplatesCache\CSharp\Windows Root\Windows\1033\ClassLibrary\csClassLibrary.vstemplate"
$global:webTemplate = "D:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\ProjectTemplatesCache\CSharp\Web\1033\WebApplicationProject40\EmptyWebApplicationProject40.vstemplate"

#variable used to store the path for the empty Habitat folder
$global:helixPath =""

#empty variable used to store the solution name
$global:solutionName = ""

#empty variable used to store the project names like Habitat to which we will add .Website
$global:projectNames = New-Object System.Collections.ArrayList

#empty variable used to store the feature name prefix like Sitecore.Foundation to which we will add foundation projects
$global:foundationNamePrefix = ""

#list of foundation projects to create
$global:foundationNames = New-Object System.Collections.ArrayList


#empty variable used to store the feature name prefix like Sitecore.Feature to which we will add feature projects
$global:featureNamePrefix = ""

#list of features to create
$global:featureNames = New-Object System.Collections.ArrayList


#Setup the folders to create
$global:folderPaths = @("\etc","\lib","\scripts","\specs","\src\Feature","\src\Foundation","\src\Project","\src\Project\Common\code","\src\Project","\src\Project\Common\code","\src\Project\Common\serialization")

$global:projectPath = "\src\Project\"
$global:foundationPath = "\src\Foundation\"
$global:featurePath = "\src\Feature\"
$global:srcFolder = "\src"
$global:codeFolder = "\code"
$global:rolesFolder = "\roles"
$global:serializationFolder = "\serialization"
$global:testsFolder = "\Tests"


$global:testProjectName = "Tests"
$global:websiteName = "Website"

$global:ConfigFolderName = "Configuration"
$global:FeatureFolderName = "Feature"
$global:FoundationFolderName = "Foundation"
$global:ProjectFolderName = "Project"


$global:solution = $null

<#
  Prompt to confirm solution creation.  
#>
function Confirm-Creation
{
     param (
           [string]$Title = 'Create Helix Solution?'
     )

     Write-Host "================ $Title ================"
     
     Write-Host "1: Continue"
     Write-Host "q: Press 'q' to Quit"
}

<#
  Prompt to accept Projects
#>
function Accept-Projects
{
     param (
           [string]$Title = 'Enter Project Names/Tenants/Sites - Site1 etc'
     )

cls
     Write-Host "================ $Title ================"
     
     Write-Host "1: Create a Project."
     Write-Host "q: Press 'q' to exit this prompt and continue to create Foundation projects."
}

<#
  Prompt to accept Foundation projects  
#>
function Accept-FoundationProjects
{
     param (
           [string]$Title = 'Enter Foundation Project Name(s)'
     )

cls     
     Write-Host "================ $Title ================"
     
     Write-Host "1: Create a Foundation Project."
     Write-Host "q: Press 'q' to exit this prompt and continue to create Feature projects."
}

<#
    Prompt to accept Feature projects
#>
function Accept-FeatureProjects
{
     param (
           [string]$Title = 'Enter Feature Project Name(s)'
     )
     cls
     Write-Host "================ $Title ================"
     
     Write-Host "1: Create a Feature Project."
     Write-Host "q: Press 'q' to exit this prompt and continue."
}

<#
    Purpose is get the information for the folder in which we are going to create the folder structure
#>
function Get-HabitatFoundationFolder
{
    #Get path and validate the path
    $global:helixPath = $input = Read-Host "Please specify the path to an empty folder"

    if($global:helixPath -eq "")
    {
        Write-Host "Select a valid folder path."
        exit
    }

    if ( -not (Test-Path $global:helixPath -PathType Container) ) 
    { 
        Write-Host "Select a valid folder."
        exit
    }

    $directoryInfo = Get-ChildItem $global:helixPath | Measure-Object
    if ($directoryInfo.count -gt 0)
    {
        Write-Host "Folder is not empty."
        exit
    }
}

<#
    Purpose is to create the base folder structure of the Habitat solution. Step 1.
#>
function Create-HabitatFoundationFolders
{

    foreach ($path in $global:folderPaths)
    {
        $newFolder = $global:helixPath + $path
        New-Item -ItemType Directory -Path $newFolder -Force    
    }

    $solution = Get-Interface $dte.Solution ([EnvDTE80.Solution2])
    $parentProject = $solution.AddSolutionFolder($global:FoundationFolderName)
    $parentSolutionFolder = Get-Interface $parentProject.Object ([EnvDTE80.SolutionFolder])

    foreach ($foundation in $global:foundationNames)
    {
    
        $newFolder = $global:helixPath + $global:foundationPath + $foundation + $global:codeFolder
        $projectName = $global:foundationNamePrefix + "." + $foundation
        $testsProjectName = $global:foundationNamePrefix + "." + $foundation + "." + $global:testProjectName

        $childProject = $parentSolutionFolder.AddSolutionFolder($foundation)
        $childSolutionFolder = Get-Interface $childProject.Object ([EnvDTE80.SolutionFolder])

        $projectFile = $childSolutionFolder.AddFromTemplate($global:webTemplate,$newFolder, $projectName);

        $newFolder = $global:helixPath + $global:foundationPath + $foundation + $global:rolesFolder
        New-Item -ItemType Directory -Path $newFolder -Force    

        $newFolder = $global:helixPath + $global:foundationPath + $foundation + $global:serializationFolder
        New-Item -ItemType Directory -Path $newFolder -Force    

        $newFolder = $global:helixPath + $global:foundationPath + $foundation + $global:testsFolder
        $projectFile = $childSolutionFolder.AddFromTemplate($global:classTemplate,$newFolder, $testsProjectName);
    }

    $solution = Get-Interface $dte.Solution ([EnvDTE80.Solution2])
    $parentProject = $solution.AddSolutionFolder($global:FeatureFolderName)
    $parentSolutionFolder = Get-Interface $parentProject.Object ([EnvDTE80.SolutionFolder])

    foreach ($feature in $global:featureNames)
    {
        $newFolder = $global:helixPath + $global:featurePath + $feature + $global:codeFolder
        $projectName = $global:featureNamePrefix + "." + $feature
        $testsProjectName = $global:featureNamePrefix + "." + $feature + "." + $global:testProjectName

        $childProject = $parentSolutionFolder.AddSolutionFolder($feature)
        $childSolutionFolder = Get-Interface $childProject.Object ([EnvDTE80.SolutionFolder])

        $projectFile = $childSolutionFolder.AddFromTemplate($global:webTemplate,$newFolder, $projectName);

        $newFolder = $global:helixPath + $global:featurePath + $feature + $global:rolesFolder
        New-Item -ItemType Directory -Path $newFolder -Force    

        $newFolder = $global:helixPath + $global:featurePath + $feature + $global:serializationFolder
        New-Item -ItemType Directory -Path $newFolder -Force    

        $newFolder = $global:helixPath + $global:featurePath + $feature + $global:testsFolder
        $projectFile = $childSolutionFolder.AddFromTemplate($global:classTemplate,$newFolder, $testsProjectName);
    }

    $solution = Get-Interface $dte.Solution ([EnvDTE80.Solution2])
    $parentProject = $solution.AddSolutionFolder($global:ProjectFolderName)
    $parentSolutionFolder = Get-Interface $parentProject.Object ([EnvDTE80.SolutionFolder])

    foreach ($project in $global:projectNames)
    {
        $newFolder = $global:helixPath + $global:projectPath + $project + $global:codeFolder
        $projectName = $global:solutionName + "." + $project + "." + $global:websiteName

        $parentSolutionFolder = Get-Interface $parentProject.Object ([EnvDTE80.SolutionFolder])
        $childProject = $parentSolutionFolder.AddSolutionFolder($project)
        $childSolutionFolder = Get-Interface $childProject.Object ([EnvDTE80.SolutionFolder])

        $projectFile = $childSolutionFolder.AddFromTemplate($global:webTemplate,$newFolder, $projectName);

        $newFolder = $global:helixPath + $global:projectPath + $project + $global:rolesFolder
        New-Item -ItemType Directory -Path $newFolder -Force    

        $newFolder = $global:helixPath + $global:projectPath + $project + $global:serializationFolder
        New-Item -ItemType Directory -Path $newFolder -Force    
    }

    Write-Host "Done creating Habitat Foundation Structure."
}

<# 
    Purpose is to accept inputs 
#>
function Accept-VSSolutionNames
{
    do
    {
        cls
        $input = Read-Host "Please specify you solution name. This could be the company name or overall solution name. e.g. Acme or MSFT "

        if([string]::IsNullOrWhiteSpace($input))
        {
            Write-Host "Empty solution name. Try again."
        }
        else
        {
            $global:solutionName = $input
        }
    }
    until (-not([string]::IsNullOrWhiteSpace($global:solutionName)))

    do
    {
        $global:foundationNamePrefix = Read-Host "Please specify you foundation name prefix. e.g."$global:solutionName".Foundation"

        if([string]::IsNullOrWhiteSpace($global:foundationNamePrefix))
        {
            Write-Host "Empty foundation name prefix. Try again."
        }
    }
    until (-not([string]::IsNullOrWhiteSpace($global:foundationNamePrefix)))

    do
    {
        $global:featureNamePrefix = Read-Host "Please specify you feature name prefix. e.g."$global:solutionName".Feature"

        if([string]::IsNullOrWhiteSpace($global:featureNamePrefix))
        {
            Write-Host "Empty feature name prefix. Try again."
        }
    }
    until (-not([string]::IsNullOrWhiteSpace($global:featureNamePrefix)))

    do
    {
         Accept-Projects
         $input = Read-Host "Enter your Project name/Tenant/Site name or q to continue. (Habitat or Site1)"
         if ($input -eq 'q')
         {
            break         
         }
         elseif (-not([string]::IsNullOrWhiteSpace($input)))
         {
               $global:projectNames.Add($input)
               #create foundation project          
         }
    }
    until ($input -eq 'q')

    do
    {
         Accept-FoundationProjects
         $input = Read-Host "Enter your Foundation project name or q to continue."
         if ($input -eq 'q')
         {
            break         
         }
         elseif (-not([string]::IsNullOrWhiteSpace($input)))
         {
               $global:foundationNames.Add($input)
               #create foundation project          
         }
    }
    until ($input -eq 'q')

    do
    {
         Accept-FeatureProjects
         $input = Read-Host "Enter your Feature project name or q to continue."
         if ($input -eq 'q')
         {
            break         
         }
         elseif (-not([string]::IsNullOrWhiteSpace($input)))
         {
               $global:featureNames.Add($input)
               #create feature project          
         }
    }
    until ($input -eq 'q')
}

<# 
    Confirm selections/input
#>
function Confirm-VSSolutionNames
{
    cls
    Write-Host "Solution Name:" $global:solutionName
    Write-Host "Project Names:" $global:projectNames
    Write-Host "Foundation Name Prefix:" $global:foundationNamePrefix
    Write-Host "Feature Name Prefix:" $global:featureNamePrefix
    Write-Host "Foundation Projects:" $global:foundationNames
    Write-Host "Feature Projects:" $global:featureNames

    Confirm-Creation

    $input = Read-Host "Enter 1 to continue or q to exit."
    if ($input -eq 'q')
    {
        exit
    }
    elseif ($input -eq '1')
    {
        $dte.Solution.Create($global:helixPath, $global:solutionName)
        $global:solution = $dte.Solution
        $dte.ExecuteCommand("File.SaveAll")

        Create-HabitatFoundationFolders

        $solution = Get-Interface $dte.Solution ([EnvDTE80.Solution2])
        $parentFolder = $solution.AddSolutionFolder($global:ConfigFolderName)
        $dte.ExecuteCommand("File.SaveAll")
    }
}

<# 
    Start function
#>
function Lets-Rumble
{
    Write-Host "    )                 (                                  (                         "
    Write-Host " ( /(     (           )\ )     (         )               )\ )                   )  "
    Write-Host " )\())  ( )\(     )  (()/(     )\  (  ( /((             (()/(    (  (        ( /(  "
    Write-Host "((_)\  ))((_)\ ( /(   /(_)) ( ((_)))\ )\())\  (   (      /(_)) ( )( )\ `  )  )\()) "
    Write-Host " _((_)/((_)((_))\()) (_))   )\ _ /((_|_))((_) )\  )\ )  (_))   )(()((_)/(/( (_))/  "
    Write-Host "| || (_))| |(_|(_)\  / __| ((_) (_))(| |_ (_)((_)_(_/(  / __| ((_|(_|_|(_)_\| |_   "
    Write-Host "| __ / -_) || \ \ /  \__ \/ _ \ | || |  _|| / _ \ ' \)) \__ \/ _| '_| | '_ \)  _|  "
    Write-Host "|_||_\___|_||_/_\_\  |___/\___/_|\_,_|\__||_\___/_||_|  |___/\__|_| |_| .__/ \__|  "
    Write-Host "                                                                      |_|          "

    Get-HabitatFoundationFolder
    Accept-VSSolutionNames
    Confirm-VSSolutionNames
}

