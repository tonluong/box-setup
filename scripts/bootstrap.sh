# bootstrap.sh
REPO_URL="https://raw.githubusercontent.com/tonluong/box-setup/main"

source <(curl -s "$REPO_URL/media.sh")
source <(curl -s "$REPO_URL/git.sh")

echo "All remote functions loaded into the current shell."
