[Reflection.Assembly]::LoadWithPartialName('Microsoft.JScript');
$js = 'var js = new ActiveXObject("WScript.Shell");js.Run("calc");'
[Microsoft.JScript.Eval]::JScriptEvaluate($js,[Microsoft.JScript.Vsa.VsaEngine]::CreateEngine());