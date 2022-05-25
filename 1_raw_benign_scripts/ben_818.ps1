$file = "consolidated-script.txt"
$filenew = "consolidated-script.sql"

cat *.sql | sc consolidated-script.txt

Rename-Item $file $filenew