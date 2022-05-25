Set-StrictMode -Version 'Latest'

Describe "ContextDSC.Tool\DomainLayer\Resource\Network\Get Network Names" {
  . "$PSScriptRoot\..\..\..\..\..\..\source\ContextDSC\ContextDSC.Tool\DomainLayer\Resource\Network\BinaryWard.ContextDSC.GetNetworkName.ps1" 

  Context 'Get network names from adapter connections' {

    # if the test server is connected to a network.
    It 'should return 1 or more network names' {
      (GetNetConnectionProfileName).Count | Should -BeGreaterThan 0
    }

    It 'should return network names as stream and each as type string' {
      GetNetConnectionProfileName | Should -BeOfType [System.String]
    }

    It 'should be able to access the result with index' {
      (GetNetConnectionProfileName)[0] | Should -BeOfType [System.String]
    }

    It 'should be able to access the result with index and the item not be null or empty' {
      (GetNetConnectionProfileName)[0] | Should -not -BeNullOrEmpty
    }
  }
}

Describe "ContextDSC.Tool\DomainLayer\Resource\Network Elevated Shell" {
  . "$PSScriptRoot\..\..\..\..\..\..\source\ContextDSC\ContextDSC.Tool\DomainLayer\Resource\Network\BinaryWard.ContextDSC.GetNetworkName.ps1" 

  Context 'Get elevated shell status' {

    It 'should return a boolean status' {
      HasElevatedShell | Should -BeofType [System.Boolean]
    }
  }
}

Describe "ContextDSC.Tool\DomainLayer\Resource\Network Network names from registry" {
  . "$PSScriptRoot\..\..\..\..\..\..\source\ContextDSC\ContextDSC.Tool\DomainLayer\Resource\Network\BinaryWard.ContextDSC.GetNetworkName.ps1" 

  Context 'Call TryGetRegistry and results are based upon elevated status' {

    if (HasElevatedShell) {
      It 'is elevated session and should return networks' {
        # this test will run if in an elevated terminal.  assumes all computers will return atleast 1 network.
        (TryGetRegistryProfileName).Count | Should -BeGreaterThan 0
      }
    }
    else {
      It 'is not elevated session and should not return networks' {
        TryGetRegistryProfileName | Should -BeNullOrEmpty
      }
    }
  
  }
}


Describe "ContextDSC.Tool\DomainLayer\Resource\Network Get Name List" {
  . "$PSScriptRoot\..\..\..\..\..\..\source\ContextDSC\ContextDSC.Tool\DomainLayer\Resource\Network\BinaryWard.ContextDSC.GetNetworkName.ps1" 

  Context 'Get network names and handle elevated shell silently' {

    It 'should return at least one network name' {
      GetNetworkName | Should -BeGreaterThan 0
    }
  }
}
