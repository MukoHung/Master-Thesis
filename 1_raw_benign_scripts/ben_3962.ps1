# Working with a [System.IO.FileInfo] Object
## Get file object into variable
PS C:\DATA> $file = Get-ChildItem C:\DATA\test.xls

## Full path name
PS C:\DATA> $file.FullName
C:\DATA\test.xls

## Filename including extension
PS C:\DATA> $file.Name
test.xls

## Filename excluding extension
PS C:\DATA> $file.BaseName
test

# Working with a simple string
## Parsing a file name from full path
PS C:\DATA> $fullPath = "C:\DATA\test.xls"

## Split string by "\"
PS C:\DATA> $elements = $fullPath.Split("\")

## Retrieve last element in array. Arrays are 0 based. To find last element take length - 1
PS C:\DATA> $elements[$($elements.Length-1)]
test.xls

## This can also be done in shorthand without a secondary variable
PS C:\DATA> $fullPath.Split("\")[-1]
test.xls

## Taking this a step further you can also parse the basename from the extension
PS C:\DATA> $fileName = $fullPath.Split("\")[-1]
PS C:\DATA> $fileName
test.xls
## Basename
PS C:\DATA> $fileName.Split(".")[0]
test

## Extension
PS C:\DATA> $fileName.Split(".")[-1]
xls

## This can easily be combined into a oneliner
### Basename from fullpath
PS C:\DATA> $fullPath.Split("\")[-1].Split(".")[0]
test

### Extension from fullpath
PS C:\DATA> $fullPath.Split("\")[-1].Split(".")[-1]
xls

# Caveats
## This string parsing will only work if the filename does not include additional periods "."
## Can be easily expanded to handle this but not neccesary for this example.