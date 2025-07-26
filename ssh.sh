#!/usr/bin/env bash
set -euo pipefail

EMAIL="${1:-}"
if [ -z "$EMAIL" ]; then
  echo "Usage: $0 <email>" >&2
  exit 1
fi

mkdir -p "$HOME/.ssh"
ssh-keygen -t ed25519 -C "$EMAIL" -f "$HOME/.ssh/id_ed25519"

eval "$(ssh-agent -s)"
ssh-add "$HOME/.ssh/id_ed25519"

if command -v pbcopy > /dev/null 2>&1; then
  pbcopy < "$HOME/.ssh/id_ed25519.pub"
  echo "Public key copied to clipboard."
else
  printf 'Public key:\n'
  cat "$HOME/.ssh/id_ed25519.pub"
fi

if command -v gh > /dev/null 2>&1; then
  gh ssh-key add "$HOME/.ssh/id_ed25519.pub" -t "$(hostname)" || true
fi
