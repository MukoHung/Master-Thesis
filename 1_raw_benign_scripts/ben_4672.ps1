#   ****************************************************************************
#   TUTORIAL PowerShell:    dataTypes
#   ****************************************************************************

<#
    PSH DataTypes
        :m01    DataTypes overview
                +   GetType()[.FullName]
        :m02    Boolean
                +   $true,$false
                +   compare     :: -eq,-not,-and,-or,-xor
        :m03    Integer
                +   compare             ::  -eq,-gt,-ge,-lt,-le
                +   artihmentics        ::  +,-,*,/
                +   modulo              ::  %
                +   increments          ::  ++,--
                +   assign and set      ::  +=,-=,*=,/=
                +   [math]::{round,floor,ceiling,pow,sqrt,log,exp,max,min}
                +   formatting integer=>string
                    +   [convert]::{ToString,ToInt32,ToInt64}
                    +   [string]::Format(<FormatString>,$iVal)
                    +   $sVal := <FormatString> -f $iVal
                    +   $sVal := <DateFormatString> -f (Get-Date)
                +   converting
                    +   integer <=> char
                        +   $cVal = [char]$iVal
                        +   $iVal = [int][char]$cVal
                    +   integer <=> string
                +   random  ::  Get-Random -minimum $iMin -maximum $iMax
        :m04    Double
        :m05    String
                :s01 define as HERE-String
                    +  single '<string>' vs double quote "<string>"
                :s02 add            ::  $s1+$s2
                :s03 ranges         ::  $c=$s[i]; $t=$s[i..j
                :s04 compare        ::  -eq,-lt,-gt
                :s05 match single   ::  -contains,-like,-notLike
                :s06 match array    ::  -In,-notIn
                :s07 properties     :: Length()
                :s08 methods or functions
                    :f01:   ToUpper(),ToLower()
                    :f02:   SubString(),IndexOf(),Remove(),Replace()
                    :f03:   Split()
                    :f04:   Trim(),TrimStart(),TrimEnd(),(Replace as Trimx)
                :s08 str2file       :: $s | Out-File $f
                :s09 multiplicator  ::  $s = 'x' * 3
        :m06    Array
                +   define,copy(clone),assign,show by:{foreach,pipe}
        :m07    Hash
                +   define,add,copy(clone),show by:{foreach,directly}
#>

#
#   =*= :   include my library
#

. .\TUT.inc.ps1 $MyInvocation.MyCommand.Name

#
#   =*= :   HEADER
#

f_lib_header(__LINE__)

#
#   =*= :   show content
#

Write-Host ""   # 1 extra line
Write-Host @"
=== :   PSH DataTypes
        :m01    DataTypes overview
        :m02    Boolean
        :m03    Integer
        :m04    Double
        :m05    String
        :m06    Array
        :m07    Hash
"@

f_lib_errorClear (__LINE__)

#
#   =*= :m01 DataType: all overview
#

f_lib_menu("dataTypes overview")(__LINE__)

#   : simple
f_lib_text('simple')
$a = $true; $x = $a.GetType(); puts "GetType(<$a>) => <$x>"     # bool
$i = -4   ; $x = $i.GetType(); puts "GetType(<$i>) => <$x>"     # int
$f = 1.52 ; $x = $f.GetType(); puts "GetType(<$f>) => <$x>"     # double
$s = 'abc'; $x = $s.GetType(); puts "GetType(<$s>) => <$x>"     # string

#   : array
f_lib_text('array')
$a = @('CLI','ELG','EMA','EML','LOG','PRT')
puts "array:= '$a'"
$x = $a[0] ; puts "a[0] =:  '$x'"
$a.GetType()    #   show with fullName
$x = $a.GetType().FullName; puts "`nGetType(<$a>) => <$x>"     # System Object[]

#   : hash
f_lib_text('hash')
$h  = @{ "Washington" = "Olympia"; "Oregon" = "Salem"; California = "Sacramento"}
puts "hStates := '$h'" # hStates := 'System.Collections.Hashtable'
$x  = $h.GetType().FullName; puts "GetType(<$h>) => <$x>"
$x = $h['Washington'] ; puts "h['Washington'] => '$x'"

#
#   =*= :m02 DataType: boolean
#

f_lib_menu("dataType: boolean")(__LINE__)

#   define
$a = $true
$b = $false
puts "a=<$a>, b=<$b>"

#   operators: compare booleans
$x = $a -eq $b;     puts "x := <$a> -eq <$b> => <$x>"
$x = -not $a;       puts "x := !<$a> => <$x>"
$x = $a -and $b;    puts "x := <$a> -and <$b> => <$x>"
$x = $a -or $b;     puts "x := <$a> -or  <$b> => <$x>"
$x = $a -xor $b;    puts "x := <$a> -xor <$b> => <$x>"

#
#   =*= :m03 DataType: integer
#

f_lib_menu("dataType: integer")(__LINE__)

$i  = 5
$j  = 3
f_lib_text('use:')
puts "i:=<$i>;j:<$j>"

#   operators: compare integer
f_lib_subMenu('compare')(__LINE__)
$x = $i -eq $j; puts "x := <$i> -eq <$j> => <$x>"       #   False
$x = $i -gt $j; puts "x := <$i> -gt <$j> => <$x>"       #   True
$x = $i -ge $j; puts "x := <$i> -ge <$j> => <$x>"       #   True
$x = $i -lt $j; puts "x := <$i> -lt <$j> => <$x>"       #   False
$x = $i -le $j; puts "x := <$i> -le <$j> => <$x>"       #   False

#   basic arithmetics
f_lib_subMenu('basic arithmentics and modulo')(__LINE__)
$x = $i + $j;    puts "x := <$i> + <$j> => <$x>"        # 8
$x = $i - $j;    puts "x := <$i> - <$j> => <$x>"        # 2
$x = $i * $j;    puts "x := <$i> * <$j> => <$x>"        # 15
$x = $i / $j;    puts "x := <$i> / <$j> => <$x>"        # 1.6666..7

#   modulo
f_lib_text('modulo')
$x = $i % $j;    puts "x := <$i> % <$j> => <$x>"        # 1

#   increments
f_lib_subMenu('inc,dec,assign')(__LINE__)

f_lib_text('++ and --')
$k=$i;  $x = ++$i * $j; puts "x := ++<$k> * <$j> => <$x> i=<$i> ";  $i=$k   # 18,6
$k=$i;  $x = $i++ * $j; puts "x := <$k>++ * <$j> => <$x> i=<$i>";   $i=$k   # 15,6
$k=$i;  $x = --$i * $j; puts "x := --<$k> * <$j> => <$x> i=<$i>";   $i=$k   # 12,4
$k=$i;  $x = $i-- * $j; puts "x := --<$k> * <$j> => <$x> i=<$i>";   $i=$k   # 15,4

f_lib_text('set and assign')
$k=$i;  $i += $j; puts "i:<$k> += j:<$j> => i=<$i>"; $i=$k  # 8
$k=$i;  $i -= $j; puts "i:<$k> -= j:<$j> => i=<$i>"; $i=$k  # 2
$k=$i;  $i *= $j; puts "i:<$k> *= j:<$j> => i=<$i>"; $i=$k  # 15
$k=$i;  $i /= $j; puts "i:<$k> /= j:<$j> => i=<$i>"; $i=$k  # 1.6..7

#   math::rounding
f_lib_subMenu('math::roundings')(__LINE__)
$x = $i / $j;
$y = [math]::round($x);     puts "y:=[math]::round(<$x>) `t=> <$y> "    # 2
$n=2; $y = [math]::round($x,$n);     puts "y:=[math]::round(<$x>,<$n>) `t=> <$y> " # 1.67
$y = [math]::truncate($x);  puts "y:=[math]::truncate(<$x>) `t=> <$y> " # 1
$i=9; $j=5; $x=$i/$j
$y = [math]::floor($x);     puts "y:=[math]::floor(<$x>) `t=> <$y> "    # 1
$y = [math]::ceiling($x);   puts "y:=[math]::ceiling(<$x>) `t=> <$y> "  # 2

#   math::transcent
f_lib_subMenu('math::power,sqrt,pi,log,exp')(__LINE__)
$i=5; $j=3
$x = [math]::pow($i,$j);    puts "x:=[math]::pow(<$i>,<$j>) `t=> <$x> " # 125
$m=27; $n = 1/3 # kubik-wurzel
$x = [math]::pow($m,$n );   puts "x:=[math]::pow(<$m>,<$n>) `t=> <$x> " # -> 3
$x = [math]::sqrt($i);      puts "x:=[math]::sqrt(<$i>) `t=> <$x>"      # 2.23...
$r=2
$x = [math]::pi * [math]::pow($r,2); puts "x:=[math]::pi*(<$r>)**2 `t=> <$x> "  # 12.566
#  # hier ist der ln(9) gemeint!    ?PHA
$x = [math]::log( 8 ); puts "x:=[math]::log(8) `t=> <$x> " # -2,07944154167984
$x = [math]::exp( 2 ); puts "x:=[math]::exp(2) `t=> <$x> " # 7,38905609893065 # = e�

#   math::max,min
$l=__LINE__; f_lib_subMenu 'math::max,min' $l
$x = [math]::max($i,$j);    puts "x:=[math]::max(<$i>,<$j>) `t=> <$x> " # 5
$x = [math]::min($i,$j);    puts "x:=[math]::min(<$i>,<$j>) `t=> <$x> " # 3

#
#   =*= formatting : Dec,Hex, Date
#

#   url:https://www.windowspro.de/script/powershell-dezimal-hex-binaer-umwandeln-ascii-werte-zeichen

f_lib_subMenu('formatting')(__LINE__)

#   *F1 use .NET conversion function "[Convert]"
f_lib_text('use: .NET [Convert]::<{ToString|ToInt32|ToInt64}>')
$i=0xA    # hex-number
$b=2; $x = [Convert]::ToString($i,$b); puts "x:=ToS('$i','$b') `t=> <'$x'> " # :1010
$b=8; $x = [Convert]::ToString($i,$b); puts "x:=ToS('$i','$b') `t=> <'$x'> " # :12
$b=10;$x = [Convert]::ToString($i,$b); puts "x:=ToS('$i','$b') `t=> <'$x'> " # :10
$b=16;$x = [Convert]::ToInt32($i,$b);  puts "x:=To32('$i','$b')`t=> <'$x'> " # :16
$b=16;$x = [Convert]::ToInt64($i,$b);  puts "x:=To64('$i','$b')`t=> <'$x'> " # :16

#   *F2 use PSH-function 'Format()'
f_lib_text('use:[String]::Format()')
$i=123
$f="{0:d5}"         # 5 dec-digits, zero-padding
$x = [String]::Format($f, $i); puts "x:=Format($f, $i) `t=> <'$x'> " # 00123
$f="{0:x5}"         # 5 hex-digits
$x = [String]::Format($f, $i); puts "x:=Format($f, $i) `t=> <'$x'> " # 0007b

#   *F3 use format-option "-f <{index[,alignment][:formatString]}>"
#       allow formatTypes for numbers: {'d','h','e'}

f_lib_text('use:-f')
#   01: hex=>dec
$i=0x123; $c='0x123'
$f="{0:d5}"         # 5 dec-digits, zero-padding
$x = $f -f $i; puts "x:= <$f> -f $i `t=> <'$x'> " # =:00291
#   02: hex=>formatted hex
$f="{0:x6}"; $x = $f -f $i; puts "x:= <$f> -f <$i> `t=> <'$x'> " # =:000123
#   03: date    # 'y':Year,'M':Month,'d':Day,'h':Hour,'s':second
$f = "{0:yyyy}-{0:MM}-{0:dd};{0:hh}:{0:mm}:{0:ss}"
$s = (Get-Date)
$x = $f -f (Get-Date)
puts "x:= <$f> -f <'$s'> `t=> <'$x'>"       # =:<'2019-03-01;09:06:03'>
#   04: truncate digits
$f = "{0:f3}"   # formatting to <float> and truncate to <3>
$y = [math]::pi
$x = $f -f $y
#   05: format 2 numbers
$f  = "'{0:f3}' && '{1:x4}'" ;  # format fields <0> and <1>
$x  = $f �f $y,$i
puts "x:= <$f> -f <'$y',$i> `t=> <$x>"      # =:<'3,142' && '0123'>
#   06: alignment of a string - pad blanks ('.')
$f  = "{0,5:d}" # format field <0> and fillUp field to length <5>
$x  = $f �f $i
puts "x:= <$f> -f <'$i'> `t=> <'$x'>"       # =:"..291"

#
#   =*= converting : integer<=>char integer<=>string
#

f_lib_subMenu('converting')(__LINE__)

#   integer<:=:>char
f_lib_text('integer<=>char')    #   $i <=> [int]([char]$c)
$i = 0x40 # use ASC
$c = '@'
#   01:     integer=>char
$x = [char]$i; puts "x:=[char]'$i' `t=> <'$x'>"     # x:=[char]'64'   => <'@'>
#   02:     char=>integer
$x = [int][char]$c; puts "x:=[int]'$c' `t=> <'$x'>" # x:=[int]'@'     => <'64'>

#   integer<:=:>string
f_lib_text('integer<=>string')  #   $i <=> [int64]([string]$s)
#   03:    string=>int64
$s = f_lib_sDateTime
$x = $i = [int64][string]$s
$t = $x.GetType()   # <'long'>
puts "x:=[int64][string]'$s' `=> x:=<'$i'>; GetType(x) => <'$t'>"
#   04:    int64=>string
$x = [string]$i
$t = $x.GetType()   # <'string'>
puts "x:=[string]($i) `=> x:=<'$i'>; GetType(x) => <'$t'>"

#   positive-decString=>integer

f_lib_text('DEC-string=>integer')

$s='123'; $bRc,$iRc = f_lib_s2i($s)
$t = $iRc.GetType()   # <'string'>
puts "y:=f($s) => bRc:=<$bRc>; iRc:=<'$iRc'>; GetType(iRc) => <'$t'>"

$s='91236'; $bRc,$iRc = f_lib_s2i($s)
$t = $iRc.GetType()   # <'string'>
puts "y:=f($s) => bRc:=<$bRc>; iRc:=<'$iRc'>; GetType(iRc) => <'$t'>"

$s='4a6'; $bRc,$iRc = f_lib_s2i($s)
$t = $iRc.GetType()   # <'string'>
puts "y:=f($s) => bRc:=<$bRc>; iRc:=<'$iRc'>; GetType(iRc) => <'$t'>"

$s='6758x'; $bRc,$iRc = f_lib_s2i($s)
$t = $iRc.GetType()   # <'string'>
puts "y:=f($s) => bRc:=<$bRc>; iRc:=<'$iRc'>; GetType(iRc) => <'$t'>"

$s='555666'; $bRc,$iRc = f_lib_s2i($s)
$t = $iRc.GetType()   # <'string'>
puts "y:=f($s) => bRc:=<$bRc>; iRc:=<'$iRc'>; GetType(iRc) => <'$t'>"
# exit(-(__LINE__))

#
#   =*= random
#

#   !URL:https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/Get-Random?view=powershell-7
#   !PHA:   $>Get-Random -Maximum $n  => only returns 0...n-1

f_lib_subMenu('random')(__LINE__)
$a = "Anton","Berta","Ceasar","David","Emil"  # 5 Elements
$i = $a.length -2
$m=10; $n=100
$x = Get-Random -Maximum $m  ;   puts "x:=rnd($m) `t=> <'$x'> " # 0..$m-1
$x = Get-Random -Minimum $m -Maximum $n; ; puts "x:=rnd[$m,$n) `t=> <'$x'> "
$x = ($a | Get-Random)  ;   puts "x:=$a|Get-Random `t=> <'$x'> "    # 1 elem of a
$x = ($a | Get-Random -count $i)  ;   puts "x:=$a|Get-Random -count $i `t=> <'$x'> " # 3 elem

#
#   =*= :m04 DataType: double(float)
#

f_lib_menu("dataType: double")(__LINE__)

$f1 = 1234567890123456789.1234
$f2 = -323.24567
$x  = $f1 * $f2;    puts "<$f1> * <$f2> => <$x>"

#
#   =*= :m05 DataType: string
#

f_lib_menu('string')(__LINE__)

#
#   =*= :s01 str defininition
#

f_lib_subMenu('string definition')(__LINE__)

#   'string' or "string"
f_lib_text('single vs double quotion mark')
$i = 45
$s1 = 'Peter ist �lter als: <$i> Jahre.'        # single-quotion
$s2 = "Peter ist �lter als: <$i> Jahre."        # double-quotion
puts "s1:<$s1>"     # s1:<Peter ist �lter als: <$i> Jahre.> => untouched
puts "s2:<$s2>"     # s2:<Peter ist �lter als: <45> Jahre.> => evaluation

#   HERE-String
#       Write a string about several lines.
f_lib_text('HERE-string with single quote')
$sHere = @'
This is a 1q-HERE-String.
Second Line.
Third Line.
'@
puts ">>> BEGIN of HERE1"
puts $sHere
puts "<<< END of HERE1"

f_lib_text('HERE-string with double quote')
$sHere = @"
This is a 2q-HERE-String.
Second Line now.
Third Line now.
"@
puts ">>> BEGIN of HERE2"
puts $sHere
puts "<<< END of HERE2"

f_lib_text('same HERE-string removed by \n \r')
#   The result is a 1-line string.
$sTmp = f_lib_chomp $sHere
puts ">>> BEGIN of HERE2b"
puts $sTmp
puts "<<< END of HERE2b"

#
#   =*= :s02 add
#

f_lib_subMenu('string add')(__LINE__)

$s1 = 'ABC'
$s2 = '123'
$x  = $s1 + $s2;    puts "x:=<$s1>+<$s2> `t=> <$x>"
$x  = "$s1$s2";     $s = "x:=" + '<"' + '$s1$s2' + '">' + "`t=> <$x>"; puts $s

#
#   =*= :s03 ranges
#

f_lib_subMenu('string char access or str ranges')(__LINE__)
$s  = 'ABCDEFGHIJ'

f_lib_text('fetch single-char')

#   c:=s[i] :: fetch 1 char
$i = 0;     $x = $s[$i];    puts "c:='$s'[$i] `t=> <$x>"    # 'A'
$i = 3;     $x = $s[$i];    puts "c:='$s'[$i] `t=> <$x>"    # 'D'

#   c:=s[-i] :: fetch 1 char by a negative offset s:=s[-x]
$i = - 1;   $x = $s[$i];    puts "c:='$s'[$i] `t=> <$x>"    # 'J'
$i = - 3;   $x = $s[$i];    puts "c:='$s'[$i] `t=> <$x>"    # 'H'

f_lib_text('fetch array-range')

#   t:=s[+i..+j] :: fetch normal range[..]
$i=0;$j=4;  $x = $s[$i..$j];    puts "a:='$s'[$i..$j] `t=> <$x>"    # @(A B C D E)
$i=3;$j=5;  $x = $s[$i..$j];    puts "a:='$s'[$i..$j] `t=> <$x>"    # @(D E F)

#   t:=s[+i..-j] or [-i +j] :: range[..]
$i=1;$j=-2;   $x = $s[$i..$j];  puts "a:='$s'[$i..$j] `t=> <$x>"    # @(B A J I)
$i=-1;$j=+2;  $x = $s[$i..$j];  puts "a:='$s'[$i..$j] `t=> <$x>"    # @(J A B C)

f_lib_text('fetch string-range')

# !PHA: instead of array range, we get string-ranges with 'join'
#   t:=s[+i..+j] :: fetch range using join
$i=2;$j=6; $x = $s[$i..$j];
$x = [system.String]::join('', $s[$i..$j])
puts "s:='$s'[$i..$j] `t=> <$x>"    # "CDEFG"

#
#   =*= :s04 str compare
#

f_lib_subMenu('string compare')(__LINE__)

$s = 'ABC'
$t = 'abc'
$x = $s -eq $t; puts "x := <$s> -eq <$t> => <$x>"       #   True ! - no case
$x = $s -lt $t; puts "x := <$s> -le <$t> => <$x>"       #   False
$x = $s -gt $t; puts "x := <$s> -gt <$t> => <$x>"       #   False
$s = 'abed'
$x = $s -gt $t; puts "x := <$s> -gt <$t> => <$x>"       #   True

#
#   =*= :s05 match single
#

f_lib_subMenu('match single')(__LINE__)

f_lib_text('match object:=string')  #   using wildcard chars '*'
$s = 'abcdefghij'
$t = 'ef'; $tw = '*ef*'
$x = $s -contains $t; puts "x := <$s> -contains <$t> => <$x>"   # FALSE
$x = $s -contains $tw; puts "x := <$s> -contains <$tw> => <$x>"   # FALSE
$x = $s -like $t; puts "x := <$s> -like <$t> => <$x>" # FALSE
$x = $s -notlike $t; puts "x := <$s> -notlike <$t> => <$x>" # TRUE
$x = $t -like $s; puts "x := <$t> -like <$s> => <$x>"   # FALSE
$x = $s -like $tw; puts "x := <$s> -like <$tw> => <$x>"   # TRUE

#
#   =*= :s06 match array of strings
#

f_lib_subMenu('match array')(__LINE__)

f_lib_text('match object:=array')
$s = 'abc','ef','gh'
$t = 'ef'
$x = $s -contains $t; puts "x := @<$s> -contains @<$t> => <$x>"     #   True
$x = $s -notcontains $t; puts "x := @<$s> -notcontains @<$t> => <$x>"     #   False
$x = $t -In $s; puts "x := @<$t> -In @<$s> => <$x>"             #   True
$x = $t -NotIn $s; puts "x := @<$t> -NotIn @<$s> => <$x>"       #   False

#
#   PSH>    $s | Get-Member # shows all methods and attributes
#

#
#   =*= :s07 properties : Length
#

f_lib_subMenu('properties')(__LINE__)

f_lib_text('string property : length')
$s = "ABCDEFGHIJ"   # s[0]='A',s[9]='J'; n=10
$x = $s.Length;     puts "x := '$s'.Length      => <$x>"    # attribute, not method

#
#   =*= :s08 methods or functions
#

#
#   =*= :f01    : ToUpper,ToLower
#

f_lib_subMenu('methods:f1:ToUpper,ToLower')(__LINE__)

$s = "Das ist eine Zeichenkette"
$t = $s.clone() # real copy
Write-Host "s:=<'$s'>"

$x = $s.ToUpper();  puts "x := '$s'.ToUpper()   => <$x>"
$x = $s.ToLower();  puts "x := '$s'.ToLower()   => <$x>"

#
#   =*= :f02    : SubString,IndexOf,Remove,Replace
#

f_lib_subMenu('methods:f2:SubString,IndexOf,Remove,Replace')(__LINE__)

$s = "ABCDEFGHIJ"        # s[0]='A',s[9]='J'; n=10
puts "s := '<$s>' "

#   indexOf
f_lib_text('indexOf')
$c='G'
$x = $s.IndexOf($c);    puts "x := '$s'.IndexOf('$c')`t=> <$x>"  # 6
$c='x'
$x = $s.IndexOf($c);    puts "x := '$s'.IndexOf('$c')`t=> <$x>"  # -1: not found

#   subString
f_lib_text('subString')
$i=5    # cut s[0]...s[i] , => s[i+1]...s[n-1]
$x = $s.SubString($i);  puts "x := '$s'.SubString($i) `t=> <'$x'>"    # <FGHI>

#   remove  - reverse method to 'subString'
f_lib_text('remove')
$i=5
$x = $s.Remove($i);     puts "x := '$s'.Remove($i) `t=> <'$x'>"       # <ABCDE>

#   replace "ABCDEFGHIJ" => "ABCxyFGHIJ"
f_lib_text('replace')
$m = 'DE'; $n='xy'
$x = $s.Replace($m,$n); puts "x := '$s'.Replace('$m','$n') `t=> <'$x'>"

#
#   =*= :f03    : Split
#

f_lib_subMenu('methods:f3:Split,Trim,TrimStart,TrimEnd')(__LINE__)

f_lib_text('split()')

#   define a multi-line string
$s = @"
Januar;Februar;
M�rz;April;Mai;Juni;Juli;August;September;Oktober;November;Dezember
"@  #   string contains `n and `r chars => we need chomp
$s = f_lib_chomp $s     # cut `r `n

$t = $s.Remove(40);     # only for output
$c = ';'
$a = $s.Split($c);  puts "x := '$t...'.Split('$c')   =>..."
$i = 0
$a | % {
    $x = $_
    $f = "{0:00}" -f $i; "`ta[$f] => $x"
    $i += 1
}

#
#   =*= :f04    : Trim,TrimStart,TrimEnd - replace(as trimX)
#

f_lib_subMenu('methods:f4:Trim,TrimStart,TrimEnd')(__LINE__)

$s1 = "   A Text-String with many Spaces    "
$s2 = "...A Text-String with many Points...."
Write-Host "s1:=<'$s1'>"
Write-Host "s2:=<'$s2'>"

f_lib_text('trim')
$x=$s1.Trim();  puts "x := s1.Trim() => `ts1:=<'$x'>"
$c='.'; $x = $s2.Trim($c);  puts "x := s2.Trim('$c') => `ts2:=<'$x'>"

f_lib_text('trimStart([<char>])')
$x = $s1.TrimStart();           puts "x := s1.TrimStart() => `ts1:=<'$x'>"
$c='.'; $x = $s2.TrimStart($c); puts "x := s2.TrimStart('$c') => `ts2:=<'$x'>"

f_lib_text('trimEnd([<char>])')
$x = $s1.TrimEnd();             puts "x := s1.TrimEnd() => `ts1:=<'$x'>"
$c='.'; $x = $s2.TrimEnd($c);   puts "x := s2.TrimEnd('$c') => `ts2:=<'$x'>"

#   replace " A BC " => "ABC" # as trim all
f_lib_text('replace(2) as trimComplete')
$m=' ';$n=''
$x = $s1.Replace($m,$n); puts "x := '$s1'.Replace2('$m','$n') `t=> <'$x'>"

#
#   =*= :s08  save str into a file
#

f_lib_text('string => files')
$f = "$g_sDirTmp/w03_String2File.out.txt"  #!CRQ-200429:whichName => Virus
$s | Out-File $f -encoding 'ascii'
$x = Get-Content $f; puts "Get-Content($f) => <$x>"

#
#   =*= :s09  multiplicator
#

f_lib_text('multiplicator')
$s='Abc'; $x = $s * 3;   puts "x := '$s' * 3 => `t = <'$x'>"


#
#   =*= :m06 DataType: array
#

f_lib_menu('array operations')(__LINE__)

#   define
$a  = @()   # empty array
$a  = @(1, 2, 3, 4)
puts "a:= <$a>"

#   copy
f_lib_text('copy an array with cloning')
$b = $a.clone()
puts "b:= <$b>"

#   add single element at the end
f_lib_text('add single element')
$a += -13
puts "a2:= <$a>"

#   change single element at special array position
f_lib_text('assign element at existing place')
$i=2; $n=-77; $a[$i] = $n
puts "b=a.clone; a[$i]:=$n  => a:=<$a>; b=<$b>"

#   show foreach
f_lib_text('show by foreach')
$i=0
foreach ($x in $a) {
    Write-Host -noNewline "a[$i]=<$x>;"
    $i++
}
Write-Host

#   show pipe
f_lib_text('show by pipe')
$i=0
$a | % {
    $x = $_
    Write-Host -noNewline "a[$i]=<$x>;"
    $i++
}
Write-Host

#
#   =*= :m07 DataType: hash
#

f_lib_menu('hash operations')(__LINE__)

#   define
$h = @{}    # empty hash

#   add manually
$h['Germany']   = 'Berlin'
$h['France']    = 'Paris'
$h['USA']       = 'Washington'
$h['Russia']    = 'Moscow'
$h['China']     = 'Being'

#   add single element
f_lib_text('add single element')
$h['USA']       = 'New-York'
puts "h = $h['USA']"

#   copy by cloning
f_lib_text('copy by cloning')
$hCountryCity   = $h.clone()
puts "hCountryCity=$hCountryCity"

#   show foreach
f_lib_text('show hCountryCity')
$hCountryCity.Keys | % {
    $key = $_                         # key
    $val = $hCountryCity.Item($_)     # value
    Write-Host "hOrg::`tCountry:<$key> `t=> City:<$val>;"
}

#   show directly
f_lib_text('show hClone')
$key = 'USA'
$val = $h['USA']
Write-Host "hCpy::`tCountry:<$key> `t=> City:<$val>;"

#
#   =*= :   FOOTER
#

f_lib_footer(__LINE__)