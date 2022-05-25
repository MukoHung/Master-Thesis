Login-AzureRMAccount
Get-AzureRmSubscription
Select-AzureRmSubscription -SubscriptionId <Your Subscription Guid>
Get-AzureRmLogicApp -ResourceGroupName <The RG Name of the LogicApp> -Name <LogicApp Name>
Get-AzureRmLogicAppTrigger -ResourceGroupName <The RG Name of the LogicApp> -Name <LogicApp Name>
Get-AzureRmLogicAppTriggerCallbackUrl -ResourceGroupName <The RG Name of the LogicApp> -Name <LogicApp Name> -TriggerName <Trigger Name>