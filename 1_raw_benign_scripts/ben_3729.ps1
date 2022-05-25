Register-EditorCommand -Name SignCurrentScript -DisplayName 'Sign Current Script' -ScriptBlock {
    $cert = (Get-ChildItem Cert:\CurrentUser\My -CodeSigningCert)[0]
    $currentFile = $psEditor.GetEditorContext().CurrentFile.Path
    Set-AuthenticodeSignature -Certificate $cert -FilePath $currentFile
}