
# INSTALLATION DE DOCKER
# Vérifie si la fonctionnalité "Conteneur" est installée
Get-WindowsFeature Containers

# Liste les fournisseurs de package disponibles
Get-PackageProvider

# Liste les modules de package disponibles
Get-Module

# Installation du provider Nugget
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force -Verbose

# Vérification des éléments installés
Get-PackageProvider
Get-WindowsFeature Containers
Get-Module

# Installation du Package Docker (redémarrage requis)
# Active la fonctionnalité Conteneur (isolation)
Install-Package -Name docker -ProviderName DockerMsftProvider -Verbose
Restart-computer
Get-WindowsFeature Containers

# Validation de l'installation du Module Containers
Get-Module

# Liste les commandes Docker
Cmd
Docker

# Version de Docker
Docker -v
# TELECHARGER DES IMAGES DOCKER
# Liste les conteneurs Docker en cours d'éxécution
Docker Image ls
Docker container ls

# Liste tous les conteneurs Docker 
Docker container ls -a

# Recherche les images Microsoft
# Le noms des fournisseurs est sensibles à la case
Docker search microsoft
Docker search nanoserver
Docker search iis

# Recherche les images Linux
Docker search linux
Docker search Ubuntu
Docker searh joomla
Docker searh wordpress

# Télécharge les images microsoft/windowsservercore et microsoft/nanoserver
Docker pull microsoft/nanoserver
Docker pull microsoft/windowsservercore

# Liste les images (microsoft/windowsservercore est disponible)
Docker image ls
Docker load < c:\sc.tar
Docker image ls
Docker container ls


# Crée un nouveau conteneur et démarre une invite PowerShell dans le conteneur
# A executer à partir d'une invite Powershell (pas d'interaction depuis Powershell ISE)
Docker run -it microsoft/windowsservercore "powershell"

# Liste les images (microsoft/windowsservercore est disponible)
# Ouvrir une autre invite PowerShell
# Copier le nom du conteneur (dernière colonne)
# Les noms sont générés de façon totalement aléatoire
Docker container ls
Docker container ls -a

# Arréter le conteneur
Docker container stop "Nom_du_conteneur"
Fermer la fenêtre PowerShell du conteneur

# Démarrer le nouveau conteneur
Docker run -it microsoft/windowsservercore "powershell"

# Valider l'adresse du conteneur
# Une adresse est générée en 172 (Nat)
# Le nom d'hôte est autogénéré !
Ipconfig
Ipconfig /all

GESTION DES CONTENEURS
# Personnalisation du conteneur
# Installe ISS et sort du conteneur
# Copier le nom du conteneur (dernière colonne) autre fenètre PowerShell
Get-WindowsFeature Web-Server
Install-WindowsFeature Web-Server
Exit

# Le conteneur est arrété !
# Docker container stop "Nom_du_conteneur" si néccessaire
Docker container ls
Docker container ls -a

# Un commutateur Nat a été crée sur l’ordinateur physique
# Un switch virtuel de type Nat est crée dans Hyper-V
# On peut se connecter au site depuis l’explorateur Windows
Ipconfig
Docker network ls
Get-ContainerNetwork
Get-VMSwitch

# Se connecter au site Web du conteneur
