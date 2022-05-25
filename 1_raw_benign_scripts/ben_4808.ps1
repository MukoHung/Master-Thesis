choco install adoptopenjdk12 -y 
choco install intellijidea-ultimate -y
choco install eclipse -y
choco install maven -y --ignore-dependencies   # Ignore JDK8 dependency 
choco install docker-desktop -y
choco install putty.install

choco install googlechrome -y 
choco install notepadplusplus -y
choco install 7zip -y 
choco install sumatrapdf.install -y
choco install nodejs.install -y
choco install vscode -y
choco install git -y 
choco install microsoft-teams -y

# tool to show .md-slides
npm i -g @infosupport/kc-cli

# Load Docker images
docker load -i C:\VPC_images\dockerimages\jenkins.tar
docker load -i C:\VPC_images\dockerimages\gitlab.tar
docker load -i C:\VPC_images\dockerimages\jira.tar
docker load -i C:\VPC_images\dockerimages\sonarqube.tar
docker load -i C:\VPC_images\dockerimages\nexus.tar
docker load -i C:\VPC_images\dockerimages\dockerregistry.tar
docker load -i C:\VPC_images\dockerimages\adoptopenjdk.tar

#############################################################################
# Fix Windows Search (Cortana)
#############################################################################
C:\VPC_images\Functions\Fix-WindowsSearch.ps1

#############################################################################
# Create task bar items
#############################################################################
$intellij = gci -Path "${env:ProgramFiles(x86)}\JetBrains\IntelliJ*\bin\idea64.exe" | select -ExpandProperty FullName
$taskBarLinks = @(
    ,$intellij
)

foreach($taskBarLink in $taskBarLinks)
{
    C:\VPC_images\Tools\syspin.exe $taskBarLink c:5386
}

#############################################################################
# Windows Explorer options
#############################################################################
Set-WindowsExplorerOptions -EnableShowFileExtensions
