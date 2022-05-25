# https://gist.github.com/timabell/bc90e0808ec1cda173ca09225a16e194
# MIT license
$exts=@(
	"csv",
	"csproj",
	"json",
	"log",
	"md",
	"patch",
	"sql",
	"txt",
	"xml")
echo "## setting up file associations"
foreach ($ext in $exts){
	$extfile=$ext+"file"
	$dotext="." + $ext
	cmd /c assoc $dotext=$extfile
	cmd /c "ftype $extfile=""C:\Program Files (x86)\Notepad++\notepad++.exe"" ""%1"""
	echo ""
}

# see also:
# * https://superuser.com/q/406985/8271
# * https://gist.github.com/timabell/608fb680bfc920f372ac