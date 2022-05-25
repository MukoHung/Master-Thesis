$MyCode = @"

public class Calc
{    
    public int Add(int a,int b)
    {
        return a+b;
    }
    
    public int Mul(int a,int b)
    {
        return a*b;
    }
    public static float Divide(int a,int b)
    {
        return a/b;
    }    
}
"@

Add-Type -TypeDefinition $MyCode -Language CSharp

$CalcInstance = New-Object -TypeName Calc

[Calc]::Divide(12, 3)

$CalcInstance.Add(20,30)

