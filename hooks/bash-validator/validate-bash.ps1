# Enhanced Bash Command Validator for Claude Code
# Prevents token waste and accidental damage by blocking commands on protected directories
# Version: 2.0

param(
    [string]$ConfigPath = ".claude/scripts/bash-validator-config.json"
)

# Read input from stdin
$input = $input | Out-String

# Parse the JSON input from Claude Code
try {
    $json = $input | ConvertFrom-Json
    $command = $json.tool_input.command
} catch {
    Write-Error "ERROR: Failed to parse input JSON"
    exit 2
}

# Default blocked patterns if config file doesn't exist
$defaultBlockedPatterns = @(
    'node_modules',
    'dist',
    'build',
    '\.git/',
    '\.chrome',
    '\.vscode',
    '\.idea',
    'coverage',
    '\.next',
    'out',
    'target',
    'bin',
    'obj'
)

$defaultAllowedCommands = @(
    'git status',
    'git log',
    'git branch',
    'git diff'
)

# Try to load config file
$blockedPatterns = $defaultBlockedPatterns
$allowedCommands = $defaultAllowedCommands
$strictMode = $false
$verbose = $false

if (Test-Path $ConfigPath) {
    try {
        $config = Get-Content $ConfigPath | ConvertFrom-Json

        if ($config.blockedDirs) {
            $blockedPatterns = $config.blockedDirs
        }

        if ($config.allowedCommands) {
            $allowedCommands = $config.allowedCommands
        }

        if ($config.strictMode -ne $null) {
            $strictMode = $config.strictMode
        }

        if ($config.verbose -ne $null) {
            $verbose = $config.verbose
        }
    } catch {
        if ($verbose) {
            Write-Warning "Could not load config from $ConfigPath, using defaults"
        }
    }
}

# Check if command is explicitly allowed (whitelist)
foreach ($allowedCmd in $allowedCommands) {
    if ($command -match "^$allowedCmd") {
        if ($verbose) {
            Write-Host "ALLOWED: Command matches whitelist: $allowedCmd"
        }
        exit 0
    }
}

# Check for blocked directory patterns
foreach ($pattern in $blockedPatterns) {
    if ($command -match $pattern) {
        $errorMsg = "ERROR: Command targets blocked directory: $pattern"

        if ($verbose) {
            Write-Error "$errorMsg`nCommand: $command"
        } else {
            Write-Error $errorMsg
        }

        exit 2
    }
}

# Strict mode: Additional checks for potentially dangerous commands
if ($strictMode) {
    # Check for destructive commands
    $destructivePatterns = @(
        'rm\s+-rf\s+/',
        'rm\s+-fr\s+/',
        'del\s+/s\s+/q\s+\\',
        'format\s+',
        'rmdir\s+/s\s+/q',
        '>\s*/dev/sd',
        'dd\s+if='
    )

    foreach ($pattern in $destructivePatterns) {
        if ($command -match $pattern) {
            Write-Error "ERROR: Potentially destructive command blocked in strict mode: $pattern"
            exit 2
        }
    }
}

if ($verbose) {
    Write-Host "ALLOWED: Command passed all validation checks"
}

exit 0
