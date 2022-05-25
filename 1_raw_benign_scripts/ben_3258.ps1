function Register-SqlAgentJob
{
    <#
    .Example
        Register-SqlAgentJob.ps1 -Name Prod_SunsetClassicAnalytics -Environment Production -Priority Medium -Category Interface
    
    .Example
        Register-SqlAgentJob.ps1 -Id 00b934c8-11d8-4889-be5f-21d9e345f2b3 -Environment Production -Priority Medium -Category Admin
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    Param(
        [Parameter(ParameterSetName = 'FindJobById', Mandatory)]
        [guid] $Id,
        [Parameter(ParameterSetName = 'FindJobByName', Mandatory)]
        [string] $Name,
        [Parameter(Mandatory)]
        [ValidateSet('ProductionDR', 'Production', 'NonProduction')]
        [string] $Environment,
        [Parameter(Mandatory)]
        [ValidateSet('Admin', 'AdminDF', 'BI', 'BizOps', 'DataFeedsETL', 'Interface', 'Pertrac')]
        [string] $Category,
        [Parameter(Mandatory)]
        [ValidateSet('Critical', 'High', 'Low', 'Medium')]
        [string] $Priority,
        [Parameter()]
        [string] $ServerInstance = 'ev-atl-bidata\mssql2k16',
        [Parameter()]
        [string] $Database = 'eVCorporate'
    )
    Begin
    {
        $LocalizedData = ConvertFrom-StringData @"
        JobNotFoundByIdError=Could not find job with ID '{0}'.
        JobNotFoundByNameError=Could not find job with Name '{0}'.
        UpdatingVerboseMessage=Updating job
"@
    
        function Get-SqlAgentJob
        {
            Param(
                [Parameter(ParameterSetName = 'FindJobById', Mandatory)]
                [guid] $Id,
                [Parameter(ParameterSetName = 'FindJobByName', Mandatory)]
                [string] $Name
            )
            Set-StrictMode -Version Latest
            
            $errorMessage = ''
            $selectQuery = "select * from [MDS].[SqlAgentJobs]"
    
            if ($PSCmdlet.ParameterSetName -eq 'FindJobById')
            {
                $selectQuery += " where SysJobID = '$Id'"
                $errorMessage = ($LocalizedData.JobNotFoundByIdError -f $Id)
            }
            
            if ($PSCmdlet.ParameterSetName -eq 'FindJobByName')
            {
                $selectQuery += " where SysJobName = '$Name'"
                $errorMessage = ($LocalizedData.JobNotFoundByNameError -f $Name)
            }
            
            $job = Invoke-SqlCmd -ServerInstance $ServerInstance -Database $Database -Query $selectQuery
            if (!$job)
            {
                throw $errorMessage
            }
            Write-Output $job
        }
    
        function Update-SqlAgentJob
        {
            [CmdletBinding(SupportsShouldProcess = $true)]
            Param(
                [Parameter(Mandatory, ValueFromPipeline)]
                [PSObject] $Job
            )
            Process
            {
                Set-StrictMode -Version Latest
                
                $updateQuery = "update [MDS].[SqlAgentJobs]
                SET MasterEnvironment = '$($Job.MasterEnvironment)'
                    ,MasterCategory = '$($Job.MasterCategory)'
                    ,MasterPriority = '$($Job.MasterPriority)'
                where SysJobId = '$($Job.SysJobId)'"
                
                if ($PSCmdlet.ShouldProcess($job.SysJobName, $LocalizedData.UpdatingVerboseMessage) -eq $true)
                {
                    Write-Verbose $LocalizedData.UpdatingVerboseMessage
                    Invoke-SqlCmd -ServerInstance $ServerInstance -Database $Database -Query $updateQuery
                }
            }
        }
    }
    Process
    {
        Set-StrictMode -Version Latest
        $params = @{}
        if ($PSCmdlet.ParameterSetName -eq 'FindJobById') {$params.Id = $Id}
        if ($PSCmdlet.ParameterSetName -eq 'FindJobByName') {$params.Name = $Name}
        $jobs = Get-SqlAgentJob @params
        
        $jobs | ForEach-Object {
            $job = $_
            $job.MasterEnvironment = $Environment
            $job.MasterCategory = $Category
            $job.MasterPriority = $Priority
            
            Update-SqlAgentJob -Job $job
            $job = Get-SqlAgentJob -Id $job.SysJobId
            Write-Output $job
        }
    }
}
