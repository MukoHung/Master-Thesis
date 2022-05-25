# show all installed fonts
# https://gist.github.com/matthewjberger/aeda92755012184e94033783027ddf3a
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
(New-Object System.Drawing.Text.InstalledFontCollection).Families