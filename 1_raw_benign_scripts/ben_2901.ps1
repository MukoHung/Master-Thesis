# Author: Matt Graeber, SpecterOps
ls C:\* -Recurse -Include '*.exe', '*.dll' -ErrorAction SilentlyContinue | % {
    try {
        $Assembly = [Reflection.Assembly]::ReflectionOnlyLoadFrom($_.FullName)

        if ($Assembly.GetReferencedAssemblies().Name -contains 'System.Management.Automation') {
            $_.FullName
        }
    } catch {}
}