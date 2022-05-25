#!/usr/bin/env pwsh

#Instructions:
#Run from the root folder

./ci/calculate-buildInfo.ps1 -isLocalBuild

Write-Host "ProductVersion: $env:BCT_PRODUCT_VERSION"
Write-Host "Branch: $env:BCT_BRANCH"
Write-Host "Release product: $env:BCT_IS_RELEASE_VERSION"
Write-Host "Build Configuration: $env:BCT_BUILD_CONFIGURATION"

#docker-login
#./ci/docker-login.ps1

#cleanup local artifacts
#./ci/cleanup.ps1

#build
./ci/build.ps1 

#setup environment
./ci/environment-setup.ps1

#db schema tests
#./ci/db-schema-unit-tests.ps1

#unit test
#./ci/unit-tests.ps1

#cleanup environment
./ci/environment-cleanup.ps1

#setup environment
./ci/environment-setup.ps1

#deploy
#./ci/deploy.ps1

#interface tests
#./ci/interface-tests.ps1 

#cleanup environment
#./ci/environment-cleanup.ps1

#publish
# ./ci/publish.ps1 

#cleanup
#./ci/cleanup.ps1
