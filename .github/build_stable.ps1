# Set strict mode, similar to 'set -e'
Set-StrictMode -Version Latest

# Store current directory path
$ORIGIN_PWD = (Get-Location).Path
# Ensure stable directory exists
if(-not (Test-Path "stable")) {
    New-Item -Path "stable" -ItemType Directory
}

# Clone git repository
if(-not (Test-Path "C:\temp")) {
    New-Item -Path "C:\temp" -ItemType Directory
}
Set-Location "C:\temp"
git clone "https://x-access-token:$env:GH_TOKEN@github.com/ITCraftDevelopmentTeam/OneDisc.git"
Set-Location "OneDisc"

# Install and update Python packages
pip install -U pip
pip install -r requirements.txt
pip install -U nuitka

# Extract version information
ls
$VERSION = & python -c 'print(__import__("version").VERSION)'
$SUB_VER = git rev-list --no-merges --count $(git describe --tags --abbrev=0)..HEAD
Write-Output "Current Version Number: $VERSION.$SUB_VER"

# Compile Python code using Nuitka
echo Yes | nuitka --onefile --standalone --follow-imports --show-modules --output-dir=build --windows-icon-from-ico=onedisc.ico --lto=yes main.py

# Move and compress the compiled file
Set-Location "build"
Rename-Item -Path "main.exe" -NewName "onedisc.exe"
Compress-Archive -Path ".\onedisc.exe" -DestinationPath "$ORIGIN_PWD\stable\OneDisc-Windows-$env:ARCH.zip"

# Commit and push changes to the repository
Set-Location $ORIGIN_PWD
git add -A
git config --global user.name "github-actions[bot]"
git config --global user.email "action@github.com"
git commit -m "Update version to $VERSION ($(Get-CimInstance Win32_OperatingSystem).caption), $env:ARCH"
git remote set-url origin "https://x-access-token:$(echo $env:GH_TOKEN_1)@github.com/This-is-XiaoDeng/OneDisc-Build.git"
git config --global pull.rebase true 
git pull
git push --force

