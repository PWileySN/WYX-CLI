# WYX-CLI with OpenCode - Quick Start Guide

## 🚀 Getting Started

### 1. Activate WYX-CLI

If you haven't already, reload your shell:
```bash
source ~/.zshrc
```

Verify installation:
```bash
wyx
```

You should see the WYX-CLI welcome screen with all available commands.

---

## 🤖 OpenCode Features

### Ask OpenCode (Interactive Chat)

Start a conversation with OpenCode directly in your terminal:

```bash
wyx ask-opencode
```

**Commands within the chat:**
- Type your questions/prompts normally
- `quit`, `exit`, or `q` - Exit the conversation
- `save` - Save conversation history to a file

**Example session:**
```
You: How do I write a bash function?
🤖: Here's how to write a bash function...

You: Can you show me an example?
🤖: Sure! Here's an example...

You: save
Enter filename to save conversation to: my-bash-questions
Conversation saved to my-bash-questions.txt

You: quit
Quitting conversation...
```

---

### Smart Commit (AI-Powered Git Commits)

Enable OpenCode to automatically generate meaningful commit messages based on your changes.

#### Setup
```bash
wyx setup smart_commit
```

This sets `USE_OPENCODE_COMMIT=true` in your `.wyx-cli-data/.env` file.

#### Usage

Make changes to your code:
```bash
# Edit some files
vim src/app.js
```

Push with smart commit:
```bash
wyx push
```

**What happens:**
1. WYX-CLI runs `git diff` and `git status`
2. Sends the changes to OpenCode
3. OpenCode analyzes the changes
4. Suggests a commit message with:
   - **Title:** Short, descriptive (≤50 chars)
   - **Description:** 2-line explanation of what/why

**Example output:**
```
OpenCode Suggestion
Title:    OpenCode-commit: Add user authentication middleware
Description: Implemented JWT token validation in auth middleware
            Added error handling for invalid/expired tokens

Press enter to use this suggestion or type your own description.
```

You can:
- Press **Enter** to accept OpenCode's suggestion
- Type your own message to override it

---

## 🔧 Configuration

### Enable/Disable Smart Commits

**Enable:**
```bash
wyx setup smart_commit
```

**Disable manually:**
```bash
# Edit the .env file
wyx keystore USE_OPENCODE_COMMIT false
```

Or edit directly:
```bash
vim /Users/pwt9708/SpringerNature/Scripts/WYX-CLI-master/.wyx-cli-data/.env
# Change: USE_OPENCODE_COMMIT=false
```

### Check Current Configuration

View your environment settings:
```bash
cat /Users/pwt9708/SpringerNature/Scripts/WYX-CLI-master/.wyx-cli-data/.env
```

Should show:
```
WYX_GIT_AUTO_UPDATE=false
USE_OPENCODE_COMMIT=true  # or false
```

---

## 💡 Tips & Tricks

### 1. Smart Commit Best Practices

- Make **focused, atomic commits** - OpenCode works best with clear, single-purpose changes
- Avoid mixing unrelated changes in one commit
- Review the suggested message before accepting
- The suggestion is just that - you can always override it

### 2. Using Ask-OpenCode Effectively

**For coding help:**
```bash
wyx ask-opencode
You: Explain the difference between $() and `` in bash
```

**For debugging:**
```bash
wyx ask-opencode
You: I'm getting 'command not found' error. How do I troubleshoot?
```

**For learning:**
```bash
wyx ask-opencode
You: What's the best way to handle errors in bash scripts?
```

### 3. Save Important Conversations

When you learn something useful in a chat session:
```bash
You: save
Enter filename: bash-error-handling-tips
```

The file will be saved in your current directory as `bash-error-handling-tips.txt`

---

## 🛠️ Troubleshooting

### OpenCode not found

If you get an error that OpenCode is not found:

1. Check if OpenCode CLI is installed:
   ```bash
   which opencode
   ```

2. If not found, you may need to install it or check your PATH

### Smart commits not working

1. Check if it's enabled:
   ```bash
   grep USE_OPENCODE_COMMIT ~/.../WYX-CLI-master/.wyx-cli-data/.env
   ```

2. Should show `USE_OPENCODE_COMMIT=true`

3. If false, enable it:
   ```bash
   wyx setup smart_commit
   ```

### Chat not responding

1. Verify OpenCode CLI is accessible:
   ```bash
   echo "Hello" | opencode
   ```

2. Check for error messages in the terminal

---

## 📚 All OpenCode-Related Commands

| Command | Description | Example |
|---------|-------------|---------|
| `wyx ask-opencode` | Start interactive chat with OpenCode | `wyx ask-opencode` |
| `wyx setup smart_commit` | Enable AI-powered commit messages | `wyx setup smart_commit` |
| `wyx push` | Git add-commit-push (uses OpenCode if enabled) | `wyx push` |
| `wyx nb <branch>` | New branch + commit + push (uses OpenCode) | `wyx nb feature-auth` |
| `wyx bpr <branch>` | New branch + PR (uses OpenCode for commits) | `wyx bpr fix-bug-123` |

---

## 🎯 Common Workflows

### Workflow 1: Feature Development with Smart Commits

```bash
# Create new branch
wyx nb feature-user-profile

# Make your changes
vim src/profile.js
vim tests/profile.test.js

# Commit and push (OpenCode generates message)
wyx push
# Press Enter to accept OpenCode's suggestion

# Create pull request
wyx pr
```

### Workflow 2: Quick Questions While Coding

```bash
# Open terminal, ask quick question
wyx ask-opencode
You: How do I iterate over an array in bash?
🤖: Here are several ways...
You: quit

# Continue coding with new knowledge
```

### Workflow 3: Learning & Saving Knowledge

```bash
wyx ask-opencode
You: Teach me about bash arrays
🤖: Bash arrays are...
You: Show me practical examples
🤖: Here are some examples...
You: save
Enter filename: bash-arrays-reference
You: quit

# Now you have bash-arrays-reference.txt for future use
```

---

## ✅ Quick Reference

**Enable everything:**
```bash
wyx setup smart_commit
wyx setup auto_update
```

**Start chatting:**
```bash
wyx ask-opencode
```

**Smart commit workflow:**
```bash
# Make changes
vim file.txt

# Push (OpenCode suggests message)
wyx push
```

**Help:**
```bash
wyx help
wyx
```

---

**Enjoy using WYX-CLI with OpenCode!** 🎉
