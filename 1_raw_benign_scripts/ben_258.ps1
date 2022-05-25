
using namespace System.Management.Automation.Language

function AnalyzeCurlUsage
{
    param([Parameter(ValueFromPipeline)][Alias('PSPath')][string]$path)

    process {
        $err = $null
        $tokens = $null
        $ast = [Parser]::ParseFile($path, [ref]$tokens, [ref]$err)
        $curlCommands = $ast.FindAll({ $n = $args[0]; $n -is [CommandAst] -and $n.GetCommandName() -eq 'curl'}, $true)
        if ($curlCommands.Count -eq 0)
        {
            # The string 'curl' was in the script, but not used as a command name.
            return [pscustomobject]@{UsesCurl = 'no'; FileName = $path.Substring($path.IndexOf('-') + 1) }
        }

        foreach ($curlCommand in $curlCommands)
        {
            foreach ($element in $curlCommand.CommandElements)
            {
                if ($element -is [CommandParameterAst] -and -not ($iwrParameters | Where-Object { $_.StartsWith($element.ParameterName, 'OrdinalIgnoreCase') } ))
                {
                    # There was a parameter that could not have been used with Invoke-WebRequest,
                    # so the presumed usage is curl.exe
                    return [pscustomobject]@{UsesCurl = 'exe'; FileName = $path.Substring($path.IndexOf('-') + 1) }
                }
            }

            $binding = [StaticParameterBinder]::BindCommand($curlCommand, $true)
            if ($binding.BindingExceptions.Count -gt 0)
            {
                # Parameters were ambiguous (possibly Invoke-WebRequest), but the static parameter binder failed
                # (possibly because of too many positional arguments), so assume the usage was curl.exe.
                return [pscustomobject]@{UsesCurl = 'exe'; FileName = $path.Substring($path.IndexOf('-') + 1) }
            }
        }

        # Not definitive, but very likely a usage of Invoke-WebRequest. A quick manual inspection of the results
        # didn't show any incorrect results here. 
        return [pscustomobject]@{UsesCurl = 'iwr'; FileName = $path.Substring($path.IndexOf('-') + 1) }
    }
}

$iwrParameters = (Get-Command Invoke-WebRequest).Parameters.Keys


# The scripts to analyzed were downloaded and saved locally with this script:
# gc .\scripts-with-curl.txt | % {$cnt = 0} { invoke-restmethod $_ -OutFile ("{0}-{1}" -f $cnt++,($_ -split '/')[-1]); start-sleep -seconds 8 }
# scripts-with-curl.txt was generated roughly like this:
# $y += 2..75 | % { write-host $_;  iwr "https://github.com/search?p=${_}&q=curl+language%3Apowershell&type=Code&utf8=%E2%9C%93"; sleep -seconds 8 }
# Then processing the Links property, but only where the link ended in ps1.  I have all the commands in my history, but it's messy ;)

dir *.ps1 | AnalyzeCurlUsage

