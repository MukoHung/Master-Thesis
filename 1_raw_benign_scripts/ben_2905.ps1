Set-AuthenticodeSignature SCRIPT @(Get-ChildItem cert:\CurrentUser\My -codesign)[0]