#!/bin/zsh
set -e
HERE="${0:A:h}"
mkdir -p "$HOME/.local/bin"
cp "$HERE/yt" "$HOME/.local/bin/yt"
chmod +x "$HOME/.local/bin/yt"
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  if ! grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
  fi
fi
print 'installed: ~/.local/bin/yt'
