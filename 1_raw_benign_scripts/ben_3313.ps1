(Get-Content ".\@NamalskIsland\meta.cpp") -replace 'publishedid = 2288339650;', 'publishedid = 2289456201;' | Out-File -encoding UTF8 ".\@NamalskIsland\meta.cpp"
(Get-Content ".\@NamalskSurvival\meta.cpp") -replace 'publishedid = 2288336145;', 'publishedid = 2289461232;' | Out-File -encoding UTF8 ".\@NamalskSurvival\meta.cpp"