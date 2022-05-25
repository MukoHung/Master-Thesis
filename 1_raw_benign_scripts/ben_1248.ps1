#$configData = @{
@{
    AllNodes = @(
        @{
            NodeName = "*"
            PSDscAllowPlainTextPassword = $true
         },
 
        @{
            NodeName = "fabfiberserver"
            Role = "WebServer,SqlServer"
         }
    );
}
 
# Note: different 1st line for RM or command line invocation
# use $configData = @{ for RM
# use @{ for running from command line