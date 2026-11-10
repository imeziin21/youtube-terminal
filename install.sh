#!/bin/zsh
set -e
HERE="${0:A:h}"
mkdir -p "$HOME/.local/bin"
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  if ! grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
  fi
fi

if ! command -v swiftc >/dev/null 2>&1; then
  echo 'error: Xcode Command Line Tools required. Run: xcode-select --install'
  exit 1
fi
mkdir -p "$HOME/.local/share/youtube-terminal"
echo 'building native floating player...'
swiftc -O -framework Cocoa -framework WebKit "$HERE/FloatingPlayer.swift" -o "$HOME/.local/share/youtube-terminal/floating-player"
echo 'installed: native Always on Top player'

cp "$HERE/yt" "$HOME/.local/bin/yt"
chmod +x "$HOME/.local/bin/yt"
print 'installed: ~/.local/bin/yt'
