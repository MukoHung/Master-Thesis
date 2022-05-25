rmdir -re -fo repo*

.  ./init-repo.ps1
. ../create-initial-files.ps1
. ../add-initial-files.ps1
. ../create-more-files.ps1

@'

    git ls-files
    ------------
'@
#
#   Note alphabetically sorted output
#
. ../ls-files.ps1

@'

    Show modified output
    --------------------
'@
. ../ls-files-m.ps1


@'

    Show other files
    ----------------
'@
. ../ls-files-o.ps1

. ../commit-1.ps1 

. ../rm.ps1
 
@'

    deleted files
    -------------
'@
. ../ls-files-d.ps1

git commit . --quiet -m "2nd commit"

cd ..
