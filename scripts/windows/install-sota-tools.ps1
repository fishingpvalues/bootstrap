# Requires -Version 5.1
$ErrorActionPreference = 'Stop'

# Ensure Scoop is installed
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host 'Installing Scoop...'
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    irm get.scoop.sh | iex
}

# Add main and extras buckets
scoop bucket add main
scoop bucket add extras
scoop bucket add nerd-fonts
scoop bucket add versions

$tools = @(
  'eza', 'bat', 'fd', 'ripgrep', 'sd', 'xh', 'gitui', 'rga', 'broot', 'dua-cli', 'ncdu', 'just', 'atuin', 'bandwhich', 'hyperfine', 'miniserve', 'dog', 'choose', 'zoxide', 'yazi', 'lazygit', 'onefetch'
)

foreach ($tool in $tools) {
    if (-not (scoop list $tool | Select-String $tool)) {
        scoop install $tool
    } else {
        Write-Host "$tool already installed."
    }
} 