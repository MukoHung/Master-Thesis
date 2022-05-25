# This is just an example of a Build.psd1
# The idea is simple: you can set values for any of the parameters of Optimize-Module in this hashtable:
@{
    # If I make a build.psd1, I always specify the path to my module's psd1
    Path = "YourModule.psd1"
    # Copy assemblies you keep in a \lib sub-folder
    CopyDirectories = "lib" 
    # Make sure we export aliases from this module
    ExportModuleMember = "Export-ModuleMember -Function *-* -Alias *"
}