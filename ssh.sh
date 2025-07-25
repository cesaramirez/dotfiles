#!/bin/sh
set -e

echo "Generating a new SSH key for GitHub..."

# Generating a new SSH key
# https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#generating-a-new-ssh-key
ssh-keygen -t ed25519 -C "$1" -f ~/.ssh/id_ed25519

# Adding your SSH key to the ssh-agent
# https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent#adding-your-ssh-key-to-the-ssh-agent
eval "$(ssh-agent -s)"

mkdir -p ~/.ssh
touch ~/.ssh/config
cat >> ~/.ssh/config <<'EOF'
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
EOF

if ssh-add --help 2>&1 | grep -q -- '--apple-use-keychain'; then
  ssh-add --apple-use-keychain ~/.ssh/id_ed25519
else
  ssh-add -K ~/.ssh/id_ed25519 2>/dev/null || ssh-add ~/.ssh/id_ed25519
fi

# Adding your SSH key to your GitHub account
# https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account
echo "run 'pbcopy < ~/.ssh/id_ed25519.pub' and paste that into GitHub"
