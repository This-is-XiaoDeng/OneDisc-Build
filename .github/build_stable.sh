set -e

export ORIGIN_PWD=$(pwd)
mkdir -p stable

cd /tmp
git clone https://x-access-token:$GH_TOKEN@github.com/ITCraftDevelopmentTeam/OneDisc.git
cd OneDisc
          
pip install -U pip
pip install -r requirements.txt
pip install -U nuitka

export VERSION=$(python -c 'print(__import__("version").VERSION)')
export SUB_VER=$(git rev-list --no-merges --count $(git describe --tags --abbrev=0)..HEAD)
# echo "VERSION=$VERSION.$SUB_VER" >> $GITHUB_ENV
echo "Currect Version Number: $VERSION.$SUB_VER"

nuitka --onefile --standalone --follow-imports --show-modules --output-dir=build --lto main.py

cd build
mv main.bin onedisc
zip -r "$ORIGIN_PWD/stable/OneDisc-$(uname)-$ARCH.zip" ./onedisc
cd $ORIGIN_PWD

git add -A
git config --global user.name "github-actions[bot]"
git config --global user.email "action@github.com"
git commit -m "Update version to $VERSION ($(uname), $ARCH)"
git remote set-url origin https://x-access-token:$GH_TOKEN@github.com/This-is-XiaoDeng/OneDisc-Build.git
git pull
git push --force
