#Require -Version 5.0

# PowerShell 5.0 now supports <using namespace NameSpace> sysntax like C#!
using namespace System;
using namespace System.Text;
using namespace System.Diagnostics;
using namespace System.Linq;
using namespace System.Collections.Generic;

class NameSpaceSyntaxTest
{
    # you can not use using namespace for Class output type.
    # [List[int]] Main() # unable to find type List[int]
    static [System.Collections.Generic.List[int]] Main()
    {
        # Stopswatch
        $sw = [Stopwatch]::StartNew();

        # List<int>
        $oldStyleListDeclare = New-Object "System.Collections.Generic.List[int]";
        $newStyleListDeclare = New-Object List[int];

        # Add item to List<int>
        [Enumerable]::Range(0,10) `
        | % {
            [Console]::WriteLine("Adding list $_. Elapsed time $($sw.Elapsed.TotalMilliseconds)ms");
            $newStyleListDeclare.Add($_);
        };

        # show final message
        $sw.Stop();
        [Console]::WriteLine("Final elapsed time $($sw.Elapsed.TotalMilliseconds)ms");

        # Return List result
        return $newStyleListDeclare;
    }
}

[NameSpaceSyntaxTest]::Main();
