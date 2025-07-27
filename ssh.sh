#!/usr/bin/env bash
set -euo pipefail

labels=( P k n E )

# Ensure SSH agent is running
if ! ssh-add -l >/dev/null 2>&1; then
  eval "$(ssh-agent -s)" >/dev/null
fi

mkdir -p "$HOME/.ssh"

config_file="$HOME/.ssh/config"
[ -f "$config_file" ] || touch "$config_file"

for label in "${labels[@]}"; do
  read -p "Correo para la cuenta ${label}: " email
  keyfile="$HOME/.ssh/id_${label}"
  if [ ! -f "$keyfile" ]; then
    ssh-keygen -t ed25519 -C "$email" -f "$keyfile" -N ""
  fi
  chmod 600 "$keyfile" "$keyfile.pub"
  ssh-add "$keyfile" 2>/dev/null || true

  if ! grep -q "^Host github.com-${label}$" "$config_file"; then
    {
      echo "Host github.com-${label}"
      echo "  HostName github.com"
      echo "  User git"
      echo "  IdentityFile ~/.ssh/id_${label}"
      echo
    } >> "$config_file"
  fi
  chmod 600 "$config_file"

done

echo "Claves públicas generadas:"
for label in "${labels[@]}"; do
  echo "  ~/.ssh/id_${label}.pub"
done
