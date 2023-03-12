# Stuff that doesn't require an admnistrator

# PowerShell config
cp $PSScriptRoot\dotfiles\profile.ps1 $profile.CurrentUserAllHosts

# Alacritty config
$alacrittyCfgDir = "$env:APPDATA\alacritty"
if (!(test-path $alacrittyCfgDir)) {
    mkdir $alacrittyCfgDir > $null
}
cp $PSScriptRoot\OS_specific\Windows\alacritty.yml $alacrittyCfgDir\alacritty.yml

