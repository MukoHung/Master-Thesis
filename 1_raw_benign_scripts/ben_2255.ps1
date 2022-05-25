Import-Module ActiveDirectory
$days = 7
$users = Search-ADAccount -AccountExpiring -TimeSpan (New-TimeSpan -Days $days)
$op=""
foreach($usr in $users)
{
    $current_user = Get-ADUser $usr.SamAccountName -Properties Manager,mail,userprincipalname,AccountExpires,DisplayName
    if ($current_user.userprincipalname -ne $null)
    {
        $user_mail = $current_user.userprincipalname
    }
    else
    {
        $user_mail = "NULL"
    }
    if ($current_user.Manager -ne $null)
    {
    write-host "Reached"
        $manager1=Get-ADUser -filter {DistinguishedName -eq $current_user.Manager} -Properties mail
        $manager_mail = $manager1.mail
    if ($manager_mail -eq $null)
    {
        $manager_mail = "NULL"    
    }
    }
    else
    {
        $manager_mail = "NULL"
    }
    write-host $current_user.Manager
    $op = $op + $current_user.SamAccountName + "/" + $current_user.DisplayName + "/" + [datetime]::FromFileTime($current_user.AccountExpires) + "/" + $user_mail + "/" + $manager_mail + "##"   
    
}
Write-Host $op