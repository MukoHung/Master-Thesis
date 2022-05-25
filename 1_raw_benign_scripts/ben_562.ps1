#Semantec Versioning Script for TeamCity

This script is a derrivative work from the Octopus Deploy team's theory of how they handle versioning their system.  Modifications were necessary to support the concept of setting the assembly's version info to be in a series, where the file's version would be more specific, to support installation updates, etc.

You're going to need the MSBuild Community Tasks project in order to update the AssemblyInfo.cs files within the solution.

Within TeamCity, the `Build files cleaner (Swarba)` `Build Feature` should be activated, and it is up to the administrator whether to set it to run before the next build starts, or at the end of the build process completing.  Do make sure the `Clean Checkout` flag is set, and it seemed to be that the `Locking processes` setting could be set to `<Do Not Detect>`

`Verbose output` is probably based on personal preference.



https://octopusdeploy.com/blog/teamcity-version-numbers-based-on-branches
http://semver.org/
http://nvie.com/posts/a-successful-git-branching-model/