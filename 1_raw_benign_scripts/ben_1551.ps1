function Get-Namespaces($assembly)
{
    $assemblyClass = [Reflection.Assembly]
    $winmdClass = [Runtime.InteropServices.WindowsRuntime.WindowsRuntimeMetadata]
    $domain = [AppDomain]::CurrentDomain
    
    # Since desktop .NET can't work with winmd files,
    # we have to use the reflection-only APIs and preload
    # all the dependencies manually.
    $appDomainHandler =
    {
        Param($sender, $e);
        $assemblyClass::ReflectionOnlyLoad($e.Name)
    }
    
    $winmdHandler =
    {
        Param($sender, $e)
        [string[]] $empty = @()
        $path = $winmdClass::ResolveNamespace($e.NamespaceName, $empty) | select -Index 0
        $e.ResolvedAssemblies.Add($assemblyClass::ReflectionOnlyLoadFrom($path))
    }
    
    # Hook up the handlers
    $domain.add_ReflectionOnlyAssemblyResolve($appDomainHandler)
    $winmdClass::add_ReflectionOnlyNamespaceResolve($winmdHandler)
    
    # Do the actual work
    $assemblyObject = $assemblyClass::ReflectionOnlyLoadFrom($assembly)
    $types = $assemblyObject.GetTypes()
    $namespaces = $types | ? IsPublic | select Namespace -Unique
    
    # Deregister the handlers
    $domain.remove_ReflectionOnlyAssemblyResolve($appDomainHandler)
    $winmdClass::remove_ReflectionOnlyNamespaceResolve($winmdHandler)
    
    return $namespaces
}