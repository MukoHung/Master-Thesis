# Modify T-SQL scripts to replace database name in 3-part object names with specified value using T-SQL script DOM.

param (
    # Path to folder containing the scripts to modify. Files with .sql extension in this folder and subfolders will be processed.
    $scriptFolderPath = "C:\source\repos\DatabaseProjects\AdventureWorks2014",
    # Original database name to replace.
    $originalDatabaseName = "AdventureWorks2014",
    # New database name or SQLCMD variable name.
    $newDatabaseName = "[`$(DatabaseName)]",
    # Location of Microsoft.SqlServer.TransactSql.ScriptDom.dll assembly.
    $scriptDomAssemblyPath = "C:\Temp\Microsoft.SqlServer.TransactSql.ScriptDom.dll",
    # Url of Microsoft.SqlServer.DacFx.x64 in official Microsoft NuGet repository.
    $scriptDomNuGetUrl = "https://www.nuget.org/api/v2/package/Microsoft.SqlServer.DacFx.x64/150.4200.1"
)

# Add type from Microsoft.SqlServer.TransactSql.ScriptDom.dll assembly, downloading latest from NuGet into this script folder if it doesn't already exist.
Function Add-TSqlScriptDomType() {

    $dacFxNuGetUrl = "https://www.nuget.org/api/v2/package/Microsoft.SqlServer.DacFx.x64"
    $scriptDomAssemblyPath = "$PSScriptRoot\Microsoft.SqlServer.TransactSql.ScriptDom.dll"

    if(![System.IO.File]::Exists($scriptDomAssemblyPath)) {
        # assembly doesn't exist in this script folder, download latest DacFx package from NuGet and extract the T-SQL Script DOM assembly here

        #download DacFx NuGet package containing assembly
        $response = Invoke-WebRequest -Uri $dacFxNuGetUrl
        if ($response.StatusCode -ne 200) {
            throw "Unable to download Microsoft.SqlServer.TransactSql.ScriptDom NuGet package: $($response.StatusCode) : $($response.StatusDescription)"
        }

        # decompress NuGet package to temp folder
        $tempZipFilePath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.IO.Path]::GetRandomFileName() + ".zip")
        [System.IO.File]::WriteAllBytes($tempZipFilePath, $response.Content)
        $response.BaseResponse.Dispose()
        $tempUnzipFolderPath = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.IO.Path]::GetRandomFileName())
        Expand-Archive -Path $tempZipFilePath -DestinationPath $tempUnzipFolderPath
        $tempZipFilePath | Remove-Item

        # copy Microsoft.SqlServer.TransactSql.ScriptDom.dll assembly and remove temp files
        Copy-Item "$tempUnzipFolderPath\lib\net*\Microsoft.SqlServer.TransactSql.ScriptDom.dll" $scriptDomAssemblyPath
        $tempUnzipFolderPath | Remove-Item -Recurse
    }
    Add-Type -Path $scriptDomAssemblyPath
}

# create TSqlGenericFragmentVisitor type that overrides and implements all abstract visitor TSqlFragmentVisitor methods
Function Create-TSqlGenericFragmentVisitorType($scriptDomAssemblyPath, $scriptDomNuGetUrl)
{

    Add-ScriptDomAssemblyType -scriptDomAssemblyPath $scriptDomAssemblyPath -scriptDomNuGetUrl $scriptDomNuGetUrl
    
    # create a dummy TSqlConcreteFragmentVisitor class to get TSqlFragmentVisitor methods
    Add-Type "public class DummyVisitor : Microsoft.SqlServer.TransactSql.ScriptDom.TSqlConcreteFragmentVisitor { public static void suppressWarning(){} }" -ReferencedAssemblies $scriptDomAssemblyPath

    # generate source code for class that overrides and implement all abstract visitor TSqlFragmentVisitor methods
    $sourceCode = @"
    using System;
    using System.Text;
    using Microsoft.SqlServer.TransactSql.ScriptDom;
    using System.Collections.Generic;

    public class TSqlGenericFragmentVisitor : TSqlFragmentVisitor
    {

        /// <summary>
        /// Visited handler invoked for every fragment 
        /// </summary>
        /// <param name="TSqlGenericFragmentVisitor">This instance</param>
        /// <param name="TSqlFragment">Current fragment</param>
        public Action<TSqlGenericFragmentVisitor, TSqlFragment> Visited;

        /// <summary>
        /// TSqlFragment stack of current and ancestor fragments
        /// </summary>
        public Stack<TSqlFragment> fragmentStack = new Stack<TSqlFragment>();

        /// <summary>
        /// Type name of current fragment
        /// </summary>
        public string CurrentTSqlFragmentTypeName
        {
            get
            {
                string currentTSqlFragmentTypeName = "";
                if(fragmentStack.Count > 0)
                {
                    var namespaceElements = fragmentStack.Peek().ToString().Split('.');
                    currentTSqlFragmentTypeName = namespaceElements[namespaceElements.Length-1];
                }
                return currentTSqlFragmentTypeName;
            }
        }

        /// <summary>
        /// Get text of specified fragment from script token stream.
        /// An empty string is returned for fragments without an underling stream (i.e. literals).
        /// </summary>
        /// <param name="fragment">TSqlFragment instance</param>
        public static string GetTSqlFragmentText(TSqlFragment fragment)
        {
            var fragmentText = new StringBuilder();
            if(fragment.ScriptTokenStream == null)
            {
                //return value from atomic token
                //fragmentText.Append(fragment.Value);
            }
            else
            {
                //get text of all values for this fragment
                for(int i = fragment.FirstTokenIndex; i <= fragment.LastTokenIndex; ++i)
                {
                    fragmentText.Append(fragment.ScriptTokenStream[i].Text);
                }
            } 
            return fragmentText.ToString();
        }

        /// <summary>
        /// Invoke Visited handler and accept child fragments
        /// </summary>
        void onVisit(TSqlFragment node)
        {
            if(Visited != null)
            {
                fragmentStack.Push(node);
                Visited(this, node);
                node.AcceptChildren(this);
                fragmentStack.Pop();
            }
        }
"@;

    # create instance of dummy type for Get-Member reflection
    [Microsoft.SqlServer.TransactSql.ScriptDom.TSqlFragmentVisitor]$dummyVisitor = New-Object DummyVisitor

    # parse method signatures to get TSqlFragmentVisitor method names to override
    $visitorMembers = $dummyVisitor | Get-Member
    $explicitVisitOverloads = $visitorMembers[5].Definition.Split("(")
    $scriptDomTypeNames = @();
    
    foreach($explicitVisitOverload in $explicitVisitOverloads)
    {
        $explicitVisitOverloadType = $explicitVisitOverload.Split(".")
        if($explicitVisitOverloadType.Length -gt 4)
        {
            $scriptDomTypeName = $explicitVisitOverloadType[4].Substring(0, $explicitVisitOverloadType[4].IndexOf(" "))
            if($scriptDomTypeName -ne "TSqlFragment")
            {
                $scriptDomTypeNames += $scriptDomTypeName
            }
        }
    
    }

    # override and implement all abstract visitor methods
    foreach($scriptDomTypeName in $scriptDomTypeNames)
    {
    $sourceCode += @"
        public override void ExplicitVisit($scriptDomTypeName node)
        {
            onVisit(node);
        }
"@;

    }

    # end of class
    $sourceCode += "}";

    # compile generate source code
    Add-Type -TypeDefinition $sourceCode -ReferencedAssemblies $scriptDomAssemblyPath

}

# replace original database name with new database name in 3-part names
Function Replace-DatabaseNames($scriptFilePath, $originalDatabaseName, $newDatabaseName) {

    $global:scriptChanged = $false
    # create new class instance for generic visitor
    $visitor = New-Object TSqlGenericFragmentVisitor

    # this handler is invoked for each visit of any fragment type
    $visitor.Visited = {
        param($obj, $node)

        $className = $obj.CurrentTSqlFragmentTypeName
        switch($className)
        {
            # when a NamedTableReference fragment is found, check if it includes a database reference to the source database name and replace with new database name if needed
            "NamedTableReference" {
                if($node.SchemaObject.DatabaseIdentifier -ne $null) {
                    $databaseName = $node.SchemaObject.DatabaseIdentifier.ScriptTokenStream[$node.SchemaObject.DatabaseIdentifier.FirstTokenIndex].Text
                    # perform case-insensitive compare of database name with and without identifier enclosures
                    if(($databaseName.ToUpper() -eq $originalDatabaseName.ToUpper()) -or ($databaseName.ToUpper() -eq "[$originalDatabaseName]".ToUpper()) -or ($databaseName.ToUpper() -eq "`"$originalDatabaseName`"".ToUpper())) {
                        # replace database name token text with specified value
                        $node.SchemaObject.DatabaseIdentifier.ScriptTokenStream[$node.SchemaObject.DatabaseIdentifier.FirstTokenIndex].Text = $newDatabaseName
                        $global:scriptChanged = $true
                    }
                }
                break
            }
            default {
                break
            }
        }

    }

    # use the appropriate TSqlParser version for the scripts being parsed
    $parser = New-Object Microsoft.SqlServer.TransactSql.ScriptDom.TSql150Parser($true)
    $parseErrors = New-Object System.Collections.Generic.List[Microsoft.SqlServer.TransactSql.ScriptDom.ParseError]
    $script = [System.IO.File]::ReadAllText($scriptFilePath)
    $scriptReader = New-Object System.IO.StringReader($script)

    $frament = $parser.Parse($scriptReader, [ref]$parseErrors)
    if($parseErrors.Count -eq 0) {
        $frament.Accept($visitor)

        if($global:scriptChanged) {
            $newScript = [TSqlGenericFragmentVisitor]::GetTSqlFragmentText($frament)
            [System.IO.File]::WriteAllText($scriptFilePath, $newScript)
            Write-Host "Changed $scriptFilePath"
        }
    }
    else {
        Write-Host "Error parsing $scriptFilePath" -ForegroundColor Red
        Write-Host "$($parseErrors.Count) parsing errors. First error: $($parseErrors[0].Message)" -ForegroundColor Red
    }

}

############
### main ###
############

# Create type that implements ExplicitVisit for all available TSqlFragmentVisitor types.
Create-TSqlGenericFragmentVisitorType -scriptDomAssemblyPath $scriptDomAssemblyPath -scriptDomNuGetUrl $scriptDomNuGetUrl

# get script files to change
$scripts = Get-ChildItem -Path ([System.IO.Path]::Combine($scriptFolderPath, "*.sql")) -Recurse
foreach($script in $scripts) {
    if($script.Mode[0] -ne "d") {
        Replace-DatabaseNames -scriptFilePath $script.FullName -originalDatabaseName $originalDatabaseName -newDatabaseName $newDatabaseName
    }
}
