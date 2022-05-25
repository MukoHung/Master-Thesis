#--Script will demonstrate File-copy with speaking voice. --# 

$source_dir="E:\folder1"
$target_dir="E:\folder2"

#-- List number of files --#

$count=0
ls ${source_dir} | select Name | foreach { $count++}
(new-object -com SAPI.SpVoice).speak("Sir! Total ${count} files to be copied. Please wait for sometime, Thank you!!")
Copy-Item "$source_dir\*.*" "$target_dir" -recurse

if ($? -ne $True )
{
  (new-object -com SAPI.SpVoice).speak("Sorry! Your file-copy operation failed, please troubleshoot!!")
}
else
{
  (new-object -com SAPI.SpVoice).speak("Sir! Your file-copy operation completed successfully, Thank you!!")
}


