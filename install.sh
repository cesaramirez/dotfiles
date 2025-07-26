#!/bin/sh
set -e

echo "Setting up your Mac..."

# Hide "last login" line when starting a new terminal session
touch $HOME/.hushlogin

# Check for Oh My Zsh and install if we don't have it
if ! command -v omz >/dev/null 2>&1; then
  /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/HEAD/tools/install.sh)"
fi

# Ensure Xcode Command Line Tools are installed
if ! xcode-select -p >/dev/null 2>&1; then
  echo "Installing Xcode Command Line Tools..."
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  clt_label=$(softwareupdate -l 2>/dev/null | awk -F'*' '/\*.*Command Line Tools for Xcode-/{sub(/^ *\*/, "", $2); print $2}' | sort -V | tail -n1)
  if [ -n "$clt_label" ]; then
    sudo softwareupdate -i "$clt_label" --verbose
    sudo rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  else
    sudo rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    echo "No suitable Command Line Tools update found. Launching GUI installer..."
    xcode-select --install 2>/dev/null || true
    echo "Please complete the installation and re-run this script."
    exit 1
  fi
  sudo xcode-select -switch /Library/Developer/CommandLineTools || true
fi

# Install Rosetta on Apple Silicon
if [ "$(uname -m)" = "arm64" ]; then
  /usr/sbin/softwareupdate --install-rosetta --agree-to-license || true
fi

# Check for Homebrew and install if we don't have it
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# You need to add brew to your PATH using
export PATH="/opt/homebrew/bin:$PATH"

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle

# Install runtime versions with mise (idempotent)
mise use -g node@20 pnpm@9 python@3.12

# Set default MySQL root password and auth type.
if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  printf "Enter MySQL root password: "
  read -r MYSQL_ROOT_PASSWORD
fi
mysql -u root -e "ALTER USER root@localhost IDENTIFIED WITH mysql_native_password BY '${MYSQL_ROOT_PASSWORD}'; FLUSH PRIVILEGES;"

# Install PHP extensions with PECL
pecl install imagick memcached redis swoole

# Install global Composer packages
/usr/local/bin/composer global require laravel/installer laravel/valet beyondcode/expose

# Install Laravel Valet
$HOME/.composer/vendor/bin/valet install

# Create a Development directory
# This is a default directory for macOS user accounts but doesn't comes pre-installed
mkdir -p "$HOME/Development"

# Configure shell and ensure runtime block exists
# Remove legacy runtime manager init lines
sed -i '' '/NVM_DIR/d' "$HOME/.zshrc" 2>/dev/null || true
sed -i '' '/nvm.sh/d' "$HOME/.zshrc" 2>/dev/null || true
sed -i '' '/pyenv init/d' "$HOME/.zshrc" 2>/dev/null || true
sed -i '' '/rbenv init/d' "$HOME/.zshrc" 2>/dev/null || true

# Add mise/direnv block if missing
if ! grep -q "# >>> dotfiles runtime >>>" "$HOME/.zshrc"; then
  cat <<'EOF' >> "$HOME/.zshrc"

# >>> dotfiles runtime >>>
eval "$(mise activate zsh)"
# eval "$(direnv hook zsh)"
# <<< dotfiles runtime <<<
EOF
fi

# Symlink the Mackup config file to the home directory
ln -s $HOME/.dotfiles/.mackup.cfg $HOME/.mackup.cfg

# You need to add brew to your PATH using
export PATH="/opt/homebrew/bin:$PATH"

# Set macOS preferences - we will run this last because this will reload the shell
source .macos

# Show installed runtime versions
node -v
pnpm -v
python --version
