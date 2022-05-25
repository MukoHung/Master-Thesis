task Clean {
    exec -maxRetries 3 {
        Get-ChildItem . -Include bin,obj,*.orig -Recurse | Remove-Item -Recurse -Force
    }
}