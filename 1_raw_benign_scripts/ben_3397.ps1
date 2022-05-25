Describe '[RUN]' {
  Context 'loadApp() Visual Studio Code' {
    It 'load Env.ps1' {
      Invoke-Command '& .\Env.ps1'
      $MyInvocation.Line | Should -BeNullOrEmpty
      $MyInvocation.InvocationName | Should -Be '& .\Env.ps1'
    }

    It 'load User.ps1' {
      Invoke-Command '& .\User.ps1'
      $MyInvocation.Line | Should -BeNullOrEmpty
      $MyInvocation.InvocationName | Should -Be '& .\User.ps1'
    }

    It 'load CA.ps1' {
      Invoke-Command '& .\CA.ps1'
      $MyInvocation.Line | Should -BeNullOrEmpty
      $MyInvocation.InvocationName | Should -Be '& .\CA.ps1'
    }

    It 'load CAExt.ps1' {
      Invoke-Command '& .\CAExt.ps1'
      $MyInvocation.Line | Should -BeNullOrEmpty
      $MyInvocation.InvocationName | Should -Be '& .\CAExt.ps1'
    }

    It 'load Util.ps1' {
      Invoke-Command '& .\Util.ps1'
      $MyInvocation.Line | Should -BeNullOrEmpty
      $MyInvocation.InvocationName | Should -Be '& .\Util.ps1'
    }
  }

  Context 'loadApp() PowerShell' {
    It 'load Env.ps1' {
      Invoke-Command '& .\Env.ps1'
      $MyInvocation.Line | Should -Be '.'
      $MyInvocation.InvocationName | Should -Be '& .\Env.ps1'
    }

    It 'load User.ps1' {
      Invoke-Command '& .\User.ps1'
      $MyInvocation.Line | Should -Be '.'
      $MyInvocation.InvocationName | Should -Be '& .\User.ps1'
    }

    It 'load CA.ps1' {
      Invoke-Command '& .\CA.ps1'
      $MyInvocation.Line | Should -Be '.'
      $MyInvocation.InvocationName | Should -Be '& .\CA.ps1'
    }

    It 'load CAExt.ps1' {
      Invoke-Command '& .\CAExt.ps1'
      $MyInvocation.Line | Should -Be '.'
      $MyInvocation.InvocationName | Should -Be '& .\CAExt.ps1'
    }

    It 'load Util.ps1' {
      Invoke-Command '& .\Util.ps1'
      $MyInvocation.Line | Should -Be '.'
      $MyInvocation.InvocationName | Should -Be '& .\Util.ps1'
    }
  }

  Context 'testApp()' {
    Invoke-Command testApp
    $MyInvocation.Line | Should -Be '.'
    $MyInvocation.InvocationName | Should -Be '& .\Util.ps1'
}

  Context 'setEnv()' {
    It 'setEnv(azure, pubca)' {
      $env = setEnv 'azure' 'pubca'
      $MyInvocation.Line | Should -Be '.'
      $env.ca | Should -BeNullOrEmpty
    }

    It 'setEnv(dev, rootca)' {
      $env = setEnv 'DEV' 'rootca'
      $env.env | Should -BeNullOrEmpty
      $env.ca | Should -BeNullOrEmpty
    }

    It 'setEnv(azure, rootca)' {
      $env = setEnv 'azure' 'rootca'
      $env.env | Should -Be 'azure'
      $env.ca | Should -Be 'rootca'
    }

    It 'setEnv(local, rootca)' {
      $env = setEnv 'local' 'rootca'
      $env.env | Should -Be 'local'
      $env.ca | Should -Be 'rootca'
    }

    It 'setEnv(npo, rootca)' {
      $env = setEnv 'npo' 'rootca'
      $env.env | Should -Be 'npo'
      $env.ca | Should -Be 'rootca'
    }

    It 'setEnv(prd, rootca)' {
      $env = setEnv 'prd' 'rootca'
      $env.env | Should -Be 'prd'
      $env.ca | Should -Be 'rootca'
    }

    It 'setEnv(tst, rootca)' {
      $env = setEnv 'tst' 'rootca'
      $env.env | Should -Be 'tst'
      $env.ca | Should -Be 'rootca'
    }

    It 'setEnv(dev, winca)' {
      $env = setEnv 'dev' 'winca'
      $env.env | Should -BeNullOrEmpty
      $env.ca | Should -BeNullOrEmpty
    }

    It 'setEnv(azure, winca)' {
      $env = setEnv 'azure' 'winca'
      $env.Env | Should -Be 'azure'
      $env.CA | Should -Be 'winca'
    }
  }
}
