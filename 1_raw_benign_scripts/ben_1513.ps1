# This fixes Permission denied errors you might get when
#  there are git symlinks being used on repositories that 
#  you share in both POSIX (usually the host) and Windows (VM).
#
# This is not an issue if you are checking out the same
#  repository separately in each platform. This is only an issue
#  when it's the same working set (aka make a change w/out 
#  committing on OSX, go to Windows VM and git status would show 
#  you that change).
#
# Based on this answer on stack overflow: http://stackoverflow.com/a/5930443/18475
#
# No warranties, good luck

$symlinks = &git ls-files -s | gawk '/120000/{print $4}'
foreach ($symlink in $symlinks) {
  write-host $symlink
  &git update-index --assume-unchanged $symlink
}