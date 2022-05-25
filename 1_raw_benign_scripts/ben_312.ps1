Param(
  [array]$region = @( "eu-west-1") 

)

foreach ($item in $region) {
    echo $item
}

#PS> .\array_as_param.ps1 us-east-1,eu-west-1
#us-east-1
#eu-west-1