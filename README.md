# ⚡️ WYX CLI ⚡️

**Optimize your development productivity in the terminal**

---

[![License](https://img.shields.io/badge/License-MIT-purple?labelColor=gray&style=flat)](LICENSE.md) ![Version](https://img.shields.io/badge/Version-3.1.3-blue?labelColor=gray&style=flat) ![Shell Support](https://img.shields.io/badge/Shell%20Support-BASH%20&%20ZSH-orange?labelColor=gray&style=flat) ![Operating Systems](https://img.shields.io/badge/OS%20Support-Debian%20Distros%20&%20MacOS-mediumpurple?labelColor=gray&style=flat) ![Git Support](https://img.shields.io/badge/Git%20Support-GitHub,%20GitLab,%20BitBucket,%20&%20Azure%20DevOps-brown?labelColor=gray&style=flat)

---

## 📚 Table of Contents

- [What It Does](#what-it-does)
- [Why It Was Made](#why-it-was-made)
- [Key Features](#key-features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [OpenCode Integration](#opencode-integration)
- [Command Categories](#command-categories)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## 🎯 What It Does

WYX-CLI is a powerful bash/zsh productivity toolkit that streamlines your terminal workflow. It provides:

- **Git Automation** - Simplified git workflows with smart commits, branch management, and PR creation
- **AI-Powered Assistance** - Integrated OpenCode for smart commit messages and interactive terminal chat
- **Directory Navigation** - Quick access to frequently used directories with custom aliases
- **Script Management** - Organize and execute your custom scripts with ease
- **Network Utilities** - IP scanning, WiFi management, port scanning, and speed tests
- **File Operations** - Encryption, search, and quick file access
- **Development Tools** - Code editor integration, multiplexed terminals, and more
- **Cross-Platform** - Works on macOS and Debian-based Linux distributions
- **Multi-Shell** - Compatible with both Bash and Zsh

---

## 💡 Why It Was Made

As developers, we repeatedly execute the same commands, navigate to the same directories, and perform identical workflows. WYX-CLI was created to:

1. **Eliminate Repetition** - Turn multi-step processes into single commands
2. **Save Time** - Navigate directories, create PRs, and manage git operations instantly
3. **Enhance Productivity** - Focus on coding, not terminal navigation
4. **Unify Workflows** - Work seamlessly across macOS and Linux environments
5. **Leverage AI** - Use OpenCode to generate meaningful commit messages automatically

---

## ✨ Key Features

### 🤖 AI-Powered Smart Commits
Generate meaningful commit messages using OpenCode based on your git diff:
```bash
wyx push  # OpenCode analyzes changes and suggests a commit message
```

### 🚀 Git Workflow Automation
```bash
wyx nb feature-auth        # Create new branch, commit, and push
wyx bpr fix-bug-123       # Create branch, commit, push, and open PR
wyx push                  # Add, commit (with AI), and push
```

### 📁 Directory Aliases
```bash
wyx cd myproject          # Jump to saved directory
wyx vsc myproject        # Open saved directory in VSCode
```

### 💬 Interactive AI Chat
```bash
wyx ask-opencode         # Start conversation with OpenCode in terminal
```

### 🔧 Script Management
```bash
wyx run deploy           # Execute your saved scripts
wyx newscript backup     # Create and edit new script
```

### 🌐 Network Tools
```bash
wyx ip                   # View local and public IPs
wyx port-scan 192.168.1.1 # Scan for open ports
wyx speedtest           # Test network speed
```

---

## 📦 Installation

### Prerequisites
- Bash 4.0+ or Zsh 5.0+
- Git
- macOS or Debian-based Linux (Ubuntu, Debian, etc.)

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/hwixley/WYX-CLI.git
   cd WYX-CLI
   ```

2. **Run the setup script**
   ```bash
   chmod +x setup.sh
   source setup.sh
   ```

3. **Reload your shell**
   ```bash
   # For Zsh
   source ~/.zshrc
   
   # For Bash
   source ~/.bashrc
   ```

4. **Verify installation**
   ```bash
   wyx
   ```

You should see the WYX-CLI welcome screen with all available command groups.

---

## 🚀 Quick Start

### Basic Commands

```bash
# View all commands
wyx

# Get version
wyx version

# View git repository URL
wyx repo

# Quick commit and push
wyx push

# Create new branch and push
wyx nb my-feature-branch

# View your todo list
wyx todo
```

### Set Up Directory Aliases

```bash
# Edit directory aliases
wyx editd mydirs

# Add entries like:
# myproject=/Users/username/Projects/myproject
# scripts=/Users/username/Scripts

# Navigate to aliases
wyx cd myproject
wyx vsc scripts  # Opens in VSCode
```

### Set Up Script Aliases

```bash
# Edit script configurations
wyx editd myscripts

# Add entries like:
# deploy=/Users/username/Scripts/deploy.sh
# backup=/Users/username/Scripts/backup.sh

# Run your scripts
wyx run deploy
wyx run backup
```

---

## 🤖 OpenCode Integration

WYX-CLI integrates with [OpenCode](https://opencode.ai) to provide AI-powered features.

### Prerequisites
OpenCode CLI must be installed. Check if it's available:
```bash
which opencode
```

### Enable Smart Commits

```bash
wyx setup smart_commit
```

This enables AI-generated commit messages when you use `wyx push`, `wyx nb`, or `wyx bpr`.

**How it works:**
1. Make changes to your code
2. Run `wyx push`
3. OpenCode analyzes your git diff
4. Suggests a title (≤50 chars) and 2-line description
5. Press Enter to accept or type your own message

**Example output:**
```
OpenCode Suggestion
Title:    Add user authentication middleware
Description: Implemented JWT token validation in auth middleware
            Added error handling for invalid/expired tokens

Press enter to use this suggestion or type your own description.
```

### Interactive AI Chat

Start a conversation with OpenCode directly in your terminal:

```bash
wyx ask-opencode
```

**Chat commands:**
- Type your questions normally
- `quit`, `exit`, or `q` - Exit conversation
- `save` - Save conversation to a file

**Example:**
```
You: How do I write a bash function?
🤖: Here's how to write a bash function...

You: save
Enter filename: bash-functions-guide
Conversation saved to bash-functions-guide.txt

You: quit
```

### Disable Smart Commits

Edit your environment file:
```bash
wyx keystore USE_OPENCODE_COMMIT false
```

Or manually edit:
```bash
vim ~/.wyx-cli-data/.env
# Change: USE_OPENCODE_COMMIT=false
```

---

## 📋 Command Categories

### VERSION 📦
- `version` - Display WYX-CLI version

### DEPENDENCIES 📦
- `install-deps` - Install WYX-CLI dependencies
- `update-deps` - Update project dependencies
- `list-deps` - List installed dependencies

### SYSTEM 🖥️
- `sys-info` - Get detailed system information

### DIRECTORY NAVIGATION 📍
- `cd <mydir?>` - Navigate to directory alias
- `back` - Go back one directory

### CODE 💲
- `run <myscript>` - Execute script alias
- `vsc <mydir>` - Open directory in VSCode
- `multiplex <cmd1> <cmd2?> ...` - Create multiplexed terminal with multiple commands

### GIT AUTOMATION 🐙
- `ginit` - Initialize git repository
- `push` - Add-commit-push to current branch
- `pull` - Pull changes for current branch
- `mpull` - Checkout and pull from master/main
- `commits` - View branch commits
- `lastcommit` - View last commit and copy SHA
- `nb <branch-name?>` - Create new branch, commit, and push
- `pr` - Open pull request from current branch
- `bpr <branch-name?>` - Create branch, commit, push, and open PR
- `pp` - Pull then push changes

### URLs 🔗
- `repo` - Open repository on GitHub/GitLab/BitBucket/Azure
- `branch` - Open current branch on hosting service
- `pipelines` - View pipelines/actions
- `issues` - View repository issues
- `prs` - View pull requests
- `notifs` - View GitHub notifications
- `profile` - View GitHub profile
- `org <myorg?>` - View GitHub organization

### ENV/KEYSTORE 🗝️
- `keystore <key?> <value?>` - Manage environment variables
- `setup <smart_commit|auto_update>` - Configure WYX-CLI features

### MY DATA 📂
- `user` - View user configuration
- `mydirs` - View directory aliases
- `myorgs` - View GitHub organization configuration
- `myscripts` - View script aliases
- `todo` - View todo list

### MANAGE MY DATA 📂
- `editd <user|myorgs|mydirs|myscripts|todo>` - Edit configurations
- `edits <myscript?>` - Edit script file
- `newscript <name?>` - Create new script

### FILE UTILITIES 📁
- `find <regex?>` - Search for files with regex
- `fopen <dir|mydir?>` - Open directory in file manager
- `encrypt <file|dir?>` - Encrypt file with GPG
- `decrypt <file?>` - Decrypt GPG file

### NETWORK UTILITIES 📡
- `ip` - View local and public IP addresses
- `wifi` - View available WiFi networks
- `hardware-ports` - View hardware ports
- `wpass` - View saved WiFi passwords
- `speedtest` - Run network speed test
- `port-scan <host?> <port-range?>` - Scan for open ports

### WEB UTILITIES 🌐
- `webtext <url?>` - View websites in terminal (read-only)

### AI UTILITIES 🤖
- `ask-opencode` - Interactive conversation with OpenCode

### TEXT UTILITIES 📝
- `genpass <pass-length?>` - Generate random password
- `genhex <length?>` - Generate random hex string
- `genb64 <length?>` - Generate random base64 string
- `lastcmd` - Copy last command to clipboard
- `copy $(<command?>)` - Copy command output to clipboard

### IMAGE UTILITIES 📸
- `genqr <url?> <name?>` - Generate QR code from URL
- `upscale <file?> <scale-multiplier?>` - Upscale image

### MISC UTILITIES 🛠️
- `weather` - View weather forecast
- `moon` - View moon phase
- `leap-year` - Check next leap year
- `quote` - Daily quote
- `today` - Daily stats

### HELP UTILITIES ℹ️
- `help` - View documentation
- `explain <command?>` - Explain bash command

---

## ⚙️ Configuration

### Configuration Files

WYX-CLI stores configuration in `.wyx-cli-data/`:

```
.wyx-cli-data/
├── .env                  # Environment variables
├── git-user.txt         # Git user configuration
├── git-orgs.txt         # GitHub organization aliases
├── dir-aliases.txt      # Directory aliases
├── run-configs.txt      # Script aliases
├── todo.txt             # Todo list
└── run-configs/         # Script storage
```

### Environment Variables

Edit `.wyx-cli-data/.env`:

```bash
WYX_GIT_AUTO_UPDATE=false        # Auto-update WYX-CLI
USE_OPENCODE_COMMIT=true         # Enable OpenCode smart commits
```

### Auto-Update

Enable automatic updates (runs when you type `wyx` with no args):

```bash
wyx setup auto_update
```

This sets `WYX_GIT_AUTO_UPDATE=true` in your `.env` file.

---

## 🔧 Troubleshooting

### Command not found: wyx

**Solution:** Reload your shell configuration
```bash
source ~/.zshrc  # or ~/.bashrc
```

### OpenCode not found

**Check if installed:**
```bash
which opencode
```

**If not found:** Install OpenCode CLI or check your PATH.

### Smart commits not working

1. **Check if enabled:**
   ```bash
   cat .wyx-cli-data/.env | grep USE_OPENCODE_COMMIT
   ```

2. **Should show:** `USE_OPENCODE_COMMIT=true`

3. **If false:**
   ```bash
   wyx setup smart_commit
   ```

### Permission denied errors

**Give execute permissions:**
```bash
chmod +x wyx-cli.sh
chmod +x setup.sh
```

### Shell compatibility issues

WYX-CLI supports both Bash and Zsh. If you encounter issues:

1. Check your shell version:
   ```bash
   echo $SHELL
   bash --version  # or zsh --version
   ```

2. Ensure you're using Bash 4.0+ or Zsh 5.0+

---

## 🤝 Contributing

Contributions are welcome! To contribute:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

---

## 🌟 Support

If you find WYX-CLI useful:
- ⭐ Star this repository
- 🐛 Report bugs via [Issues](https://github.com/hwixley/wyx-cli/issues)
- 💡 Suggest features
- ☕ [Buy me a coffee](https://www.buymeacoffee.com/hwixley)

---

## 📝 Version History

### v3.1.3 (Current)
- ✅ OpenCode integration for smart commits
- ✅ Interactive AI chat in terminal
- ✅ Cross-platform macOS and Linux support
- ✅ Bash and Zsh compatibility
- ✅ GitHub, GitLab, BitBucket, and Azure DevOps support

---

**Made with ⚡ by developers, for developers**
