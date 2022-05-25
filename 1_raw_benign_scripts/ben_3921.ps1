#############################################################################################################
#
# SSH connect test for Github, Gitlab, and Bitbucket.
#
# Copyright (c) 2021, S. Tarık Çetin.
# MIT licence.
#
#############################################################################################################

Write-Host "`n"
Write-Host "====== Connecting to Github via SSH"
ssh -T git@github.com


Write-Host "`n"
Write-Host "`n"
Write-Host "====== Connecting to Gitlab via SSH"
ssh -T git@gitlab.com


Write-Host "`n"
Write-Host "`n"
Write-Host "====== Connecting to Bitbucket via SSH"
ssh -T git@bitbucket.org


Write-Host "`n"
Write-Host "`n"
Write-Host "====== All done. You can close this window now."
