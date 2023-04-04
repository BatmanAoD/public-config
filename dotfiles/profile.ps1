Set-PSReadLineOption -EditMode vi
Import-Alias ~\public-config\ps-aliases.csv

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
