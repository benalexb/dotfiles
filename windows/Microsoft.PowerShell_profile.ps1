# Find out if the current user identity is elevated (has admin rights)
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal $identity
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Set up window title. Use UNIX-style convention for identifying
# whether user is elevated (root) or not. Window title shows current version of PowerShell
# and appends [ADMIN] if appropriate for easy taskbar identification
if ($isAdmin) {
  $Host.UI.RawUI.WindowTitle = "[Admin] "
  $Host.UI.RawUI.WindowTitle += "PowerShell {0}" -f $PSVersionTable.PSVersion.ToString()
} else {
  $Host.UI.RawUI.WindowTitle = "PowerShell {0}" -f $PSVersionTable.PSVersion.ToString()
}

# Simple function to start a new elevated process. If arguments are supplied then
# a single command is started with admin rights; if not then a new admin instance
# of PowerShell is started.
function admin {
  if ($args.Count -gt 0) {
    $argList = "& '" + $args + "'"
    Start-Process "~/AppData/Local/Microsoft/WindowsApps/wt.exe" -Verb runAs -ArgumentList $argList
  } else {
    Start-Process "~/AppData/Local/Microsoft/WindowsApps/wt.exe" -Verb runAs
  }
}

# Set UNIX-like aliases for the admin command, so sudo <command> will run the command
# with elevated rights.
Set-Alias -Name su -Value admin
Set-Alias -Name sudo -Value admin

Set-Alias -Name ll -Value ls

# Similar to UNIX which command
function which($name) {
  Get-Command $name | Select-Object -ExpandProperty Definition
}

# We don't need these any more; they were just temporary variables to get to $isAdmin.
# Delete them to prevent cluttering up the user profile.
Remove-Variable identity
Remove-Variable principal

oh-my-posh init pwsh --config '~/posh-themes/powerlevel10k_lean.omp.json' | Invoke-Expression

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
