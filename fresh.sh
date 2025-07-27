#!/usr/bin/env bash
set -euo pipefail

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"
BREWFILE="$DOTFILES/Brewfile"

# Install Xcode Command Line Tools if needed
if ! xcode-select -p > /dev/null 2>&1; then
  echo "Installing Xcode Command Line Tools..."
  sudo touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  clt_label=$(softwareupdate -l 2> /dev/null | awk -F'*' '/\*.*Command Line Tools for Xcode-/{sub(/^ *\*/, "", $2); print $2}' | sort -V | tail -n1)
  if [ -n "$clt_label" ]; then
    sudo softwareupdate -i "$clt_label" --verbose
    sudo rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  else
    sudo rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    echo "GUI installer required. Complete it and re-run this script."
    xcode-select --install 2> /dev/null || true
    exit 1
  fi
  if [ -d /Library/Developer/CommandLineTools ]; then
    sudo xcode-select -switch /Library/Developer/CommandLineTools
  fi
fi

# Install Rosetta on Apple Silicon
if [ "$(uname -m)" = "arm64" ]; then
  /usr/sbin/softwareupdate --install-rosetta --agree-to-license || true
fi

# Install Homebrew if missing
if ! command -v brew > /dev/null 2>&1; then
  tmp=$(mktemp)
  curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$tmp"
  NONINTERACTIVE=1 /bin/bash "$tmp"
  rm -f "$tmp"
fi

# Evaluate Homebrew environment
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"

elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

brew analytics off

# Skip Mac App Store apps if not signed in
if grep -q '^mas ' "$BREWFILE"; then
  command -v mas >/dev/null 2>&1 || brew install mas
  if ! mas account >/dev/null 2>&1; then
    echo "Skipping Mac App Store apps: not signed in"
    export HOMEBREW_BUNDLE_MAS_SKIP=1
  fi
fi

brew bundle --file "$BREWFILE"

# Install Oh My Zsh locally if absent
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
fi

ZSH_BLOCK=$(cat <<'EOF'
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$DOTFILES"
[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"
[ -f "$ZSH_CUSTOM/path.zsh" ] && source "$ZSH_CUSTOM/path.zsh"
[ -f "$ZSH_CUSTOM/aliases.zsh" ] && source "$ZSH_CUSTOM/aliases.zsh"
EOF
)

if ! grep -q "ZSH_CUSTOM=\$DOTFILES" "$HOME/.zshrc" 2> /dev/null; then
  printf '\n%s\n' "$ZSH_BLOCK" >> "$HOME/.zshrc"
fi

# Configure git includes
if ! grep -q "gitconfig.dotfiles" "$HOME/.gitconfig" 2> /dev/null; then
  {
    echo "[include]"
    echo "    path = ~/.gitconfig.dotfiles"
  } >> "$HOME/.gitconfig"
fi

if [ ! -f "$HOME/.gitconfig.dotfiles" ]; then
  cat << 'GIT' > "$HOME/.gitconfig.dotfiles"
[core]
  pager = delta
[pull]
  ff = only
[merge]
  conflictstyle = zdiff3
GIT
fi

# Install runtimes with mise if available
if command -v mise > /dev/null 2>&1; then
  mise use -g node@20 pnpm@9 python@3.12 || true
fi

# Display versions
echo
command -v brew > /dev/null && brew --version | head -n1
command -v git > /dev/null && git --version
command -v node > /dev/null && node --version
command -v pnpm > /dev/null && pnpm --version
command -v python > /dev/null && python --version
