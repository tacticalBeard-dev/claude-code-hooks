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

5. **Customize the configuration** (see Customization section below)

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

## Customization Guide

### Adding Directories to Block

To add more directories to ignore, edit `.claude/scripts/bash-validator-config.json`:

1. **Open the config file** in your project:
   ```bash
   # Edit .claude/scripts/bash-validator-config.json
   ```

2. **Add directory patterns to the blockedDirs array:**
   ```json
   {
     "blockedDirs": [
       "node_modules",
       "dist",
       "\\\\.git/",
       "your-new-directory",
       "another-folder"
     ]
   }
   ```

3. **Save the file** - changes take effect immediately

### Regex Pattern Examples

Since `blockedDirs` uses regex patterns, remember to escape special characters:

| Directory | Pattern | Notes |
|-----------|---------|-------|
| `node_modules` | `"node_modules"` | Simple directory name |
| `.git/` | `"\\\\.git/"` | Escape dots (4 backslashes in JSON) |
| `dist` or `build` | `"(dist\\|build)"` | Multiple options |
| Any `.cache` folder | `"\\\\.cache"` | Matches `.cache` anywhere |
| `temp*` folders | `"temp.*"` | Wildcard matching |
| Exact `.vscode` only | `"^\\\\.vscode$"` | Anchored match |

**Why 4 backslashes?**
- JSON requires `\\` to represent one backslash
- Regex requires `\` before special chars like `.`
- So `\\.` becomes `\\\\.` in JSON

### Adding Allowed Commands

To whitelist commands that should bypass blocking:

```json
{
  "allowedCommands": [
    "git status",
    "git log",
    "git branch",
    "npm --version",
    "du -sh node_modules"
  ]
}
```

Commands matching these patterns will always be allowed, even if they target blocked directories.

### Project-Specific Examples

**JavaScript/TypeScript:**
```json
{
  "blockedDirs": [
    "node_modules",
    "dist",
    "build",
    "\\\\.git/",
    "coverage",
    "\\\\.next",
    "out",
    "\\\\.nuxt",
    "\\\\.output"
  ]
}
```

**Python:**
```json
{
  "blockedDirs": [
    "venv",
    "env",
    "\\\\.venv",
    "__pycache__",
    "\\\\.pytest_cache",
    "\\\\.git/",
    "dist",
    "build",
    "\\\\.tox",
    "eggs",
    "\\\\.eggs"
  ]
}
```

**Rust:**
```json
{
  "blockedDirs": [
    "target",
    "\\\\.git/",
    "vendor",
    "\\\\.cargo"
  ]
}
```

**.NET:**
```json
{
  "blockedDirs": [
    "bin",
    "obj",
    "packages",
    "\\\\.git/",
    "\\\\.vs",
    "TestResults",
    "\\\\.nuget"
  ]
}
```

**Go:**
```json
{
  "blockedDirs": [
    "vendor",
    "\\\\.git/",
    "bin"
  ]
}
```

### Adding New Hook Types

To contribute additional hook types to this repository:

1. **Create hook directory:**
   ```bash
   mkdir -p hooks/your-hook-name
   ```

2. **Add your hook script(s):**
   ```
   hooks/your-hook-name/
   ├── your-script.ps1 (or .sh for bash)
   ├── config.json (optional)
   └── config.schema.json (optional)
   ```

3. **Create template:**
   ```
   templates/your-hook-name/
   ├── settings.local.json
   └── config.json
   ```

4. **Update README** with usage instructions

5. **Submit pull request**

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
    "npm list --depth=0",
    "du -sh node_modules"
  ]
}
```

### Multiple Environment Configs

Create different configs per environment:

```
.claude/scripts/
├── bash-validator-config.json          # Default
├── bash-validator-config.dev.json      # Development
└── bash-validator-config.strict.json   # CI/Production
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

### Testing Your Regex Patterns

To test if a pattern matches correctly:

1. Enable verbose mode:
   ```json
   { "verbose": true }
   ```

2. Try commands and watch the output
3. Adjust patterns as needed
4. Disable verbose when satisfied

**Pattern Tips:**
- Start simple: `"node_modules"` works for most cases
- Add anchors only if needed: `"^dist$"` for exact match
- Escape dots: `"\\\\.git/"` for `.git/`
- Test with both blocked and allowed commands

## Troubleshooting

### Hook Not Running

1. Verify `.claude/settings.local.json` contains hook configuration
2. Check `validate-bash.ps1` exists in `.claude/scripts/`
3. Ensure PowerShell execution policy allows scripts
4. Enable `verbose: true` for detailed logs

### Commands Not Being Blocked

1. Check regex patterns in `blockedDirs`
2. Escape special regex characters (e.g., `\\\\.git/`)
3. Enable verbose mode to see pattern matching
4. Verify hook is running (see above)

### Commands Incorrectly Blocked

1. Add command pattern to `allowedCommands`
2. Adjust `blockedDirs` patterns to be more specific
3. Use verbose mode to see why it's blocked
4. Check for false positives in patterns

### Pattern Not Matching

Common issues:
- Forgot to escape dots: Use `\\\\.git/` not `.git/`
- Too many/few backslashes: JSON needs 4 for regex dot
- Pattern too broad: `".*dist.*"` matches "distributed"
- Pattern too narrow: `"^dist$"` won't match `dist/`

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
