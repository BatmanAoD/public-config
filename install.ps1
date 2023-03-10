#Requires -RunAsAdministrator

Set-ExecutionPolicy RemoteSigned

# Install Chocolatey
if (-Not (Get-Command choco -errorAction SilentlyContinue)) {
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

choco install -y git pwsh gsudo neovide zulip microsoft-windows-terminal
# TODO remove '--pre' if/when package gets approved
choco install -y --pre xmouse-controls --version 1.1.0.0

# PowerShell config
cp $PSScriptRoot\dotfiles\profile.ps1 $profile.CurrentUserAllHosts

# Don't beep at me
set-service beep -startuptype disabled

# Install WSL
$wsl_info = wsl -l -v
if ($?) {
    echo "WSL is already installed."
}
else {
    wsl --install
}
