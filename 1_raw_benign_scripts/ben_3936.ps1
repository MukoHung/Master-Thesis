# You should have: installed Docker Toolbox along with VirtualBox.
# This was tested on Win8.1.

docker-machine rm default;
docker-machine create default --driver virtualbox;
# docker-machine env default;
& "C:\Program Files\Docker Toolbox\docker-machine.exe" env default | Invoke-Expression;
# From now on should be able to use Docker API; f.e. type `docker ps` to see running containers.