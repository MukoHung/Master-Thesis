@"
class foo
{
  [string] static bar([string] $text)
  {
    return $text
  }
}
"@ > class.psm1

import-module ./class.psm1
$m = get-module class
. $m { [foo]::bar('hello') }
$text = "bye"
. $m { param($string) [foo]::bar($string) } ( $text )
