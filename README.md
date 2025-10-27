# Claude Code Hooks

A collection of reusable hooks and scripts for [Claude Code](https://claude.ai/code) to enhance safety, productivity, and consistency across projects.

## Overview

This repository provides ready-to-use hooks that help you:

- **Prevent costly mistakes** - Block commands that could damage your project or waste tokens
- **Enforce best practices** - Automatically validate commands before execution
- **Standardize workflows** - Use the same protective measures across all your projects
- **Customize per project** - Easy configuration files for project-specific needs

## Available Hooks

### Bash Validator

Prevents Claude Code from running commands on protected directories.

**Features:**
- Configurable blocked directories
- Whitelist for always-allowed commands
- Strict mode for blocking destructive commands
- Verbose logging for debugging
- JSON schema for IDE autocomplete

**Benefits:**
- Saves tokens by preventing expensive searches in dependency folders
- Protects build artifacts
- Prevents accidental version control corruption
- Blocks destructive commands in strict mode

## Quick Start

### Installation

1. **Create directory structure in your project:**
   ```bash
   mkdir -p .claude/scripts
   ```

2. **Copy the validator script:**
   ```bash
   curl -o .claude/scripts/validate-bash.ps1 \
     https://raw.githubusercontent.com/tacticalBeard-dev/claude-code-hooks/main/hooks/bash-validator/validate-bash.ps1
   ```

3. **Copy the configuration file:**
   ```bash
   curl -o .claude/scripts/bash-validator-config.json \
     https://raw.githubusercontent.com/tacticalBeard-dev/claude-code-hooks/main/templates/basic/bash-validator-config.json
   ```

4. **Copy or merge the settings file:**
   ```bash
   curl -o .claude/settings.local.json \
     https://raw.githubusercontent.com/tacticalBeard-dev/claude-code-hooks/main/templates/basic/settings.local.json
   ```

5. **Customize the configuration** (optional)

### Manual Installation

1. Create `.claude/scripts/` directory in your project
2. Copy files from this repository:
   - `hooks/bash-validator/validate-bash.ps1` to `.claude/scripts/validate-bash.ps1`
   - `templates/basic/bash-validator-config.json` to `.claude/scripts/bash-validator-config.json`
   - `templates/basic/settings.local.json` to `.claude/settings.local.json`
3. Customize configuration as needed

## Configuration

### Bash Validator Config

Edit `.claude/scripts/bash-validator-config.json`:

```json
{
  "blockedDirs": [
    "node_modules",
    "dist",
    "build",
    "\\\\.git/"
  ],
  "allowedCommands": [
    "git status",
    "git log"
  ],
  "strictMode": false,
  "verbose": false
}
```

**Options:**

- **blockedDirs** (array): Regex patterns for directories to block
- **allowedCommands** (array): Commands that are always allowed (whitelist)
- **strictMode** (boolean): Block potentially destructive commands
- **verbose** (boolean): Enable detailed logging

### Project-Specific Examples

**JavaScript/TypeScript:**
```json
{
  "blockedDirs": ["node_modules", "dist", "build", "\\\\.git/", "coverage", "\\\\.next"]
}
```

**Python:**
```json
{
  "blockedDirs": ["venv", "env", "__pycache__", "\\\\.pytest_cache", "\\\\.git/"]
}
```

**Rust:**
```json
{
  "blockedDirs": ["target", "\\\\.git/", "vendor"]
}
```

**.NET:**
```json
{
  "blockedDirs": ["bin", "obj", "packages", "\\\\.git/", "\\\\.vs"]
}
```

## How It Works

1. Claude Code attempts a bash command
2. PreToolUse hook intercepts the command
3. Script checks command against configuration
4. Command is allowed or blocked based on rules

### Example Commands

**Blocked:**
- `grep -r "test" node_modules/`
- `find .git/ -type f`
- `ls dist/`

**Allowed:**
- `grep -r "test" src/`
- `git status`
- `cat package.json`

## Testing

Verify the hook is working:

1. Run: `ls src/` (should work)
2. Run: `ls node_modules/` (should be blocked)
3. Check error message confirming hook is active

Enable `verbose: true` for detailed logs.

## Advanced Usage

### Strict Mode

Blocks potentially destructive commands:

```json
{
  "strictMode": true
}
```

This blocks patterns like `rm -rf /`, `format`, `dd if=`

### Custom Allowed Commands

Whitelist specific commands:

```json
{
  "allowedCommands": [
    "git status",
    "npm list --depth=0"
  ]
}
```

### Multiple Environment Configs

Create different configs per environment:

```
.claude/scripts/
├── bash-validator-config.json
├── bash-validator-config.dev.json
└── bash-validator-config.strict.json
```

Reference specific config in `settings.local.json`:

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{
        "type": "command",
        "command": "powershell -ExecutionPolicy Bypass -File .claude/scripts/validate-bash.ps1 -ConfigPath .claude/scripts/bash-validator-config.strict.json"
      }]
    }]
  }
}
```

## Troubleshooting

### Hook Not Running

1. Verify `.claude/settings.local.json` contains hook configuration
2. Check `validate-bash.ps1` exists in `.claude/scripts/`
3. Ensure PowerShell execution policy allows scripts
4. Enable `verbose: true` for detailed logs

### Commands Not Being Blocked

1. Check regex patterns in `blockedDirs`
2. Escape special regex characters (e.g., `\\\\.git/`)
3. Enable verbose mode
4. Verify hook is running

### Commands Incorrectly Blocked

1. Add command pattern to `allowedCommands`
2. Adjust `blockedDirs` patterns to be more specific
3. Use verbose mode to debug

## Contributing

Contributions welcome! To add a new hook:

1. Create directory under `hooks/`
2. Add hook script(s)
3. Create configuration schema (optional)
4. Add template under `templates/`
5. Update README
6. Submit pull request

## License

MIT License - see LICENSE file for details

## Resources

- [Claude Code Documentation](https://docs.claude.com/claude-code)
- [Claude Code Hooks Guide](https://docs.claude.com/claude-code/hooks)
