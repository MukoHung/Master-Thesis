dotnet new sln
dotnet new angular -n SOLUTION_NAME.Website -o SOLUTION_NAME.Website
dotnet new mstest -n SOLUTION_NAME.Tests -o SOLUTION_NAME.Tests
dotnet sln add SOLUTION_NAME.Website\SOLUTION_NAME.Website.csproj
dotnet sln add SOLUTION_NAME.Tests\SOLUTION_NAME.Tests.csproj
cd SOLUTION_NAME.Tests
dotnet add reference ..\SOLUTION_NAME.Website\SOLUTION_NAME.Website.csproj
cd ..
dotnet restore