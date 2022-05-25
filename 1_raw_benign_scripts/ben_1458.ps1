# Copy your Tampermonkey storage.js into the same directory as this script.
# It'll extract the user scripts from storage.js and write them as .user.js files
# in the current working directory.

add-type -as System.Web.Extensions
$JSON = new-object Web.Script.Serialization.JavaScriptSerializer
$obj = $JSON.DeserializeObject((gc storage.js))

foreach ($key in $obj.keys) {
	foreach ($val in $obj[$key].value) {
		if ($val -match "\r?\n//\s+@name\s+(.+)\r?\n") {
			$val | out-file ("{0}.user.js" -f $matches[1])
		}
	}
}