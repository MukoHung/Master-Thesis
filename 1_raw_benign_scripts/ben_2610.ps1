###############################################################################
#
#   NuGet Package Deployment Script
#
#   Param: target - The name of the csproj or nuspec file to package and deploy
#
#   Note: You need to specify your API key and NuGet feed url in the script below.
#
###############################################################################

param($target)

# Retrieve file object for targeted nuget spec of C# project.
$specOrProj = Get-ChildItem $target

# Perform replace on the target file's extension so we can derive what the NuGet package name is going to be.
$package = $specOrProj.FullName.Replace(".csproj", ".*.nupkg")
$package = $package.Replace(".nuspec", ".*.nupkg")

# Get NuGet to package the target
nuget pack $specOrProj.FullName

# Search for the resulting NuGet package.
$package = Get-ChildItem $package

# Push the NuGet package to the server using the API key and URL defined below.
nuget push $package.FullName <YourApiKeyHere> -s http://nugetfeedurl

# Delete the generated nuget package.
del $package.FullName
