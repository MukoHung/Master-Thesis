# Publish the application to a folder
dotnet publish C:\Projects\RandomQuotes\RandomQuotes.sln --output published-app --configuration Release

# Package the folder into a ZIP
octo pack --id RandomQuotes --version $env:APPVEYOR_BUILD_VERSION --basePath C:\projects\RandomQuotes\RandomQuotes\published-app

# Push Build Artifact AppVeyor Deployment with Octopus
appveyor PushArtifact C:\projects\randomquotes\RandomQuotes.$env:APPVEYOR_BUILD_VERSION.nupkg -Type OctopusPackage