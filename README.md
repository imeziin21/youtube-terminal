# YouTube Terminal

**Control YouTube directly from your macOS terminal.**

YouTube Terminal is a lightweight command-line tool that lets you search, play, and control YouTube videos without interrupting your workflow.

With a native macOS floating player, you can keep videos visible while working in other applications.

This project was built using vibe coding.

## Features

- **YouTube Search** — Search for videos directly from your terminal.
- **Terminal Control** — Control YouTube using simple CLI commands.
- **Floating Player** — Keep videos visible above other application windows.
- **Dark & Light Mode** — Switch between themes manually.
- **Playback Control** — Play, pause, and resume videos.
- **Resizable Player** — Adjust the player window size.
- **Google Sign-In** — Sign in to YouTube through the player.

## Installation

### Requirements

- macOS
- Google Chrome
- Swift compiler (Xcode Command Line Tools)

### Setup

Clone the repository:

```bash
git clone https://github.com/imeziin21/youtube-terminal.git
cd youtube-terminal
```

Run the installation script:

```bash
chmod +x install.sh
./install.sh
```

## Usage

| Command | Description |
|---|---|
| `yt search <query>` | Search for YouTube videos from the terminal |
| `yt play` | Play a YouTube video |
| `yt pause` | Pause playback |
| `yt resume` | Resume playback |
| `yt pin` | Open the always-on-top floating player |
| `yt unpin` | Disable always-on-top mode |
| `yt dark` | Enable dark mode |
| `yt light` | Enable light mode |
| `yt size 400 300` | Resize the player window |

## YouTube Search

Search for YouTube videos without leaving your terminal.

```bash
yt search flutter tutorial
```

Use the search results to find videos you want to watch.

## Always on Top

Keep YouTube videos visible while switching between Chrome tabs, using your IDE, or working in other applications.

```bash
yt pin
```

To disable always-on-top mode:

```bash
yt unpin
```

The floating player is built with Swift and WebKit, using native macOS window management.

## Theme Switching

Switch between dark and light themes directly from your terminal.

```bash
yt dark
yt light
```

Your selected theme is saved for future sessions.

## Tech Stack

- **Python** — Command-line interface
- **Swift** — Native macOS floating player
- **WebKit** — Embedded YouTube player
- **AppleScript** — Browser automation

## Platform Support

Currently available for **macOS only**.

## License

See the repository's LICENSE file for details.
