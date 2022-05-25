<#
USAGES:
    xaas-avi-networks-sim-endpoint.ps1 -targetEnv prod|test|dev -targetTenant test|itservices|epfl|research -action create -bgId <bgId> -deploymentTag test|development|production -targetElement vm -lbLayer L4 -lbType custom   -svcFriendlyName <svcFriendlyName> -vipType public|private
    xaas-avi-networks-sim-endpoint.ps1 -targetEnv prod|test|dev -targetTenant test|itservices|epfl|research -action create -bgId <bgId> -deploymentTag test|development|production -targetElement vm -lbLayer L7 -lbType standard -svcFriendlyName <svcFriendlyName> -vipType public|private 
    xaas-avi-networks-sim-endpoint.ps1 -targetEnv prod|test|dev -targetTenant test|itservices|epfl|research -action updateHostList -bgId <bgId> -poolId <poolId> -deploymentTag <deploymentTag> -hostList <hostList>
    
#>
<#
    BUT 		: Permet de gérer le service AVI Network qui fourni des Load Balancers

	DATE 	: Février 2021
    AUTEUR 	: Lucien Chaboudez
    
    REMARQUES : 
    - Avant de pouvoir exécuter ce script, il faudra changer la ExecutionPolicy via Set-ExecutionPolicy. 
        Normalement, si on met la valeur "Unrestricted", cela suffit à correctement faire tourner le script. 
        Mais il se peut que si le script se trouve sur un share réseau, l'exécution ne passe pas et qu'il 
        soit demandé d'utiliser "Unblock-File" pour permettre l'exécution. Ceci ne fonctionne pas ! A la 
        place il faut à nouveau passer par la commande Set-ExecutionPolicy mais mettre la valeur "ByPass" 
        en paramètre.


    FORMAT DE SORTIE: Le script utilise le format JSON suivant pour les données qu'il renvoie.
    {
        "error": "",
        "results": []
    }

    error -> si pas d'erreur, chaîne vide. Si erreur, elle est ici.
    results -> liste avec un ou plusieurs éléments suivant ce qui est demandé.

    DOCUMENTATION: TODO:

#>

param([string]$targetEnv, 
      [string]$targetTenant, 
      [string]$action, 
      [string]$bgId,
      [string]$poolId,
      [string]$deploymentTag,           # Valeurs de [DeploymentTag]
      [string]$targetElement,           # Valeurs de [XaaSAviTargetElement]
      [Array]$hostList,                 # Le fait de mettre [Array] et de passer une liste de valeurs séparées par des virgules va automatiquement mettre le tout dans un tableau
      [string]$lbType,                  # Valeurs de [XaaSAviLBType]
      [string]$lbLayer,                 # Valeurs de [XaaSAviLBLayer]
      [Array]$lbFrontPortList,          # Liste de ports séparée par des virgules
      [Array]$lbFrontPortsListIsHttp2,  # Liste de true|false séparée par des virgules
      [string]$vipType,                 # Valeurs de [XaaSAviVipType]
      [string]$svcFriendlyName,
      [string]$lbAlgo,                  # Valeurs de [XaaSAviLBAlgorithm]
      [string]$lbAlgoHash,              # Valeurs de [XaaSAviLBAlgorithmHash]
      [string]$lbAlgoHashCustHead, 
      [string]$lbPersist,
      [Array]$lbHealMon)

# Inclusion des fichiers nécessaires (génériques)
. ([IO.Path]::Combine("$PSScriptRoot", "include", "define.inc.ps1"))
. ([IO.Path]::Combine("$PSScriptRoot", "include", "functions.inc.ps1"))
. ([IO.Path]::Combine("$PSScriptRoot", "include", "LogHistory.inc.ps1"))
. ([IO.Path]::Combine("$PSScriptRoot", "include", "ConfigReader.inc.ps1"))
. ([IO.Path]::Combine("$PSScriptRoot", "include", "NotificationMail.inc.ps1"))
. ([IO.Path]::Combine("$PSScriptRoot", "include", "Counters.inc.ps1"))
. ([IO.Path]::Combine("$PSScriptRoot", "include", "NameGeneratorBase.inc.ps1"))
. ([IO.Path]::Combine("$PSScriptRoot", "include", "NameGenerator.inc.ps1"))
. ([IO.Path]::Combine("$PSScriptRoot", "include", "SecondDayActions.inc.ps1"))

# Fichiers propres au script courant 
. ([IO.Path]::Combine("$PSScriptRoot", "include", "XaaS", "functions.inc.ps1"))

# Chargement des fichiers pour API REST
. ([IO.Path]::Combine("$PSScriptRoot", "include", "REST", "APIUtils.inc.ps1"))
. ([IO.Path]::Combine("$PSScriptRoot", "include", "REST", "RESTAPI.inc.ps1"))
. ([IO.Path]::Combine("$PSScriptRoot", "include", "REST", "RESTAPICurl.inc.ps1"))
. ([IO.Path]::Combine("$PSScriptRoot", "include", "REST", "SnowAPI.inc.ps1"))
. ([IO.Path]::Combine("$PSScriptRoot", "include", "REST", "vRAAPI.inc.ps1"))



# Chargement des fichiers de configuration
$configGlobal = [ConfigReader]::New("config-global.json")


# -------------------------------------------- CONSTANTES ---------------------------------------------------

# Liste des actions possibles
$ACTION_CREATE              = "create"
$ACTION_UPDATE_HOST_LIST    = "updateHostList"
$ACTION_DELETE              = "delete"


# ----------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------
# ---------------------------------------------- PROGRAMME PRINCIPAL ---------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------
# ----------------------------------------------------------------------------------------------------------------------

try
{
    # Création de l'objet pour l'affichage 
    $output = getObjectForOutput

    # Création de l'objet pour logguer les exécutions du script (celui-ci sera accédé en variable globale même si c'est pas propre XD)
    # TODO: Adapter la ligne suivante
    $logHistory = [LogHistory]::new(@('xaas','avi-networks', 'endpoint'), $global:LOGS_FOLDER, 30)
    
        # Objet pour pouvoir envoyer des mails de notification
	$valToReplace = @{
		targetEnv = $targetEnv
		targetTenant = $targetTenant
	}
	$notificationMail = [NotificationMail]::new($configGlobal.getConfigValue(@("mail", "admin")), $global:MAIL_TEMPLATE_FOLDER, `
												($global:VRA_MAIL_SUBJECT_PREFIX -f $targetEnv, $targetTenant), $valToReplace)

                                                
    # On commence par contrôler le prototype d'appel du script
    . ([IO.Path]::Combine("$PSScriptRoot", "include", "ArgsPrototypeChecker.inc.ps1"))

    # Autres checks
    if($lbFrontPortList.count -ne $lbFrontPortsListIsHttp2.count)
    {
        Throw ("-lbFrontPortList and -lbFrontPortsListIsHttp2 parameters must have the same number of elements")
    }

    # Ajout d'informations dans le log
    $logHistory.addLine(("Script executed as '{0}' with following parameters: `n{1}" -f $env:USERNAME, ($PsBoundParameters | ConvertTo-Json)))
        
    <# Pour enregistrer des notifications à faire par email. Celles-ci peuvent être informatives ou des erreurs à remonter
	aux administrateurs du service
	!! Attention !!
	A chaque fois qu'un élément est ajouté dans le IDictionnary ci-dessous, il faut aussi penser à compléter la
	fonction 'handleNotifications()'

	(cette liste sera accédée en variable globale même si c'est pas propre XD)
    #>
    # TODO: A adapter en ajoutant des clefs pointant sur des listes
	$notifications=@{
                    }
                                                
    # On met en minuscules afin de pouvoir rechercher correctement dans le fichier de configuration (vu que c'est sensible à la casse)
    $targetEnv = $targetEnv.ToLower()
    $targetTenant = $targetTenant.ToLower()


    # En fonction de l'action demandée
    switch ($action)
    {

        # -- Création d'un nouveau LoadBalancer
        $ACTION_CREATE {
            $output.results += @{
                poolId = ("pool-{0}" -f (-join ((65..90) + (97..122) | Get-Random -Count 20 | % {[char]$_})))
            }
            

        }# FIN Action Create


        # -- Modification d'un LoadBalancer
        $ACTION_UPDATE_HOST_LIST {

        }


        # -- Effacement d'un LoadBalancer
        $ACTION_DELETE {
            
        }

    }

    $logHistory.addLine("Script execution done!")


    # Affichage du résultat
    displayJSONOutput -output $output

    # Ajout du résultat dans les logs 
    $logHistory.addLine(($output | ConvertTo-Json -Depth 100))

    
}
catch
{
	# Récupération des infos
	$errorMessage = $_.Exception.Message
	$errorTrace = $_.ScriptStackTrace

    # Ajout de l'erreur et affichage
    $output.error = "{0}`n`n{1}" -f $errorMessage, $errorTrace
    displayJSONOutput -output $output


	$logHistory.addError(("An error occured: `nError: {0}`nTrace: {1}" -f $errorMessage, $errorTrace))
    
    # On ajoute les retours à la ligne pour l'envoi par email, histoire que ça soit plus lisible
    $errorMessage = $errorMessage -replace "`n", "<br>"

	# Création des informations pour l'envoi du mail d'erreur
	$valToReplace = @{	
        scriptName = $MyInvocation.MyCommand.Name
        computerName = $env:computername
        parameters = (formatParameters -parameters $PsBoundParameters )
        error = $errorMessage
        errorTrace =  [System.Net.WebUtility]::HtmlEncode($errorTrace)
    }

    # Envoi d'un message d'erreur aux admins 
    $notificationMail.send("Error in script '{{scriptName}}'", "global-error", $valToReplace) 
}