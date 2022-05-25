# Prerequisites
# Not required for Windows Server 2012

# Custom pre-installation scripts 

# Create Directories before running setup!
MD "X:\Program Files\Microsoft SQL Server"
MD "X:\Program Files (x86)\Microsoft SQL Server"

# Setup
Y:\setup.exe /configurationfile="X:\SQLConfigurationFile.ini" 