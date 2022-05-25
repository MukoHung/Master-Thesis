New-WebServiceProxy: Creates a Web service proxy object that lets you use and manage the Web service in Windows PowerShell.
Example: PS C:\> $zip = New-WebServiceProxy -Uri "http://www.webservicex.net/uszip.asmx?WSDL"
         PS C:\> $udpProxy | Get-Member -MemberType Method