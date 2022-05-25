# clone the Bench project
git clone -b dev https://github.com/winbench/bench.git ".\bench dev"
cd ".\bench dev"

# clone the development configuration
git clone https://github.com/winbench/config-dev.git ".\config"

# clone the app libraries
git clone https://github.com/winbench/apps-core.git .\applibs\core
git clone https://github.com/winbench/apps-default.git .\applibs\default

# load the app libraries into the Bench environment
robocopy .\applibs .\libs\applibs /MIR /XD .git /NJH /NJS

# build Bench in debug mode
build\build-debug.ps1

# initialize the Bench environment
auto\bin\bench.exe -v m i
