configuration DemoConfig {

    Import-DscResource -ModuleName PSDesiredStateConfiguration
	Import-DscResource -ModuleName ComputerManagementDSC

    Node 'localhost' {
    
        xDSCFirewall DomainProfileOff
                    {
        Zone = "Domain"
        Ensure = "Absent"
    }

        xDSCFirewall PrivateProfileOff
                    {
        Zone = "Private"
        Ensure = "Absent"
    }

        xDSCFirewall PublicProfileff
                    {
        Zone = "Public"
        Ensure = "Absent"
    }

    
    }

}DemoConfig