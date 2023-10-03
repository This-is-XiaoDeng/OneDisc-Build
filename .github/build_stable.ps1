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
$VERSION = & python -c 'print(__import__("version").VERSION)'
$SUB_VER = git rev-list --no-merges --count $(git describe --tags --abbrev=0)..HEAD
Write-Output "Current Version Number: $VERSION.$SUB_VER"

# Compile Python code using Nuitka
nuitka --onefile --standalone --follow-imports --show-modules --output-dir=build --lto main.py

# Move and compress the compiled file
Set-Location "build"
Rename-Item -Path "main.bin" -NewName "onedisc"
Compress-Archive -Path "./onedisc" -DestinationPath "$ORIGIN_PWD/stable/OneDisc-$(Get-CimInstance Win32_OperatingSystem).caption-$env:ARCH.zip"

# Commit and push changes to the repository
Set-Location $ORIGIN_PWD
git add -A
git config --global user.name "github-actions[bot]"
git config --global user.email "action@github.com"
git commit -m "Update version to $VERSION ($(Get-CimInstance Win32_OperatingSystem).caption), $env:ARCH"
git remote set-url origin "https://x-access-token:$env:GH_TOKEN@github.com/This-is-XiaoDeng/OneDisc-Build.git"
git pull
git push --force

