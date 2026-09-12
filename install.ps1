<#
.SYNOPSIS
    Installs puzzle-game-ui skill globally or into a specific project for multiple IDEs/AI agents.
.PARAMETER Scope
    'Global' (default) installs into user-level directories (~/.agents/skills and ~/.claude/skills).
    'Project' installs into a specified repository.
.PARAMETER TargetPath
    Path to the target project directory (required when Scope is 'Project').
.PARAMETER Method
    'Link' (default, uses NTFS junction/symlink for auto-sync) or 'Copy'.
#>
[CmdletBinding()]
param(
    [ValidateSet('Global', 'Project')]
    [string]$Scope = 'Global',

    [string]$TargetPath = '',

    [ValidateSet('Link', 'Copy')]
    [string]$Method = 'Link'
)

$sourceDir = $PSScriptRoot
Write-Host "Source skill directory: $sourceDir" -ForegroundColor Cyan

function Install-SkillDir {
    param([string]$DestPath, [string]$SourcePath, [string]$Method)
    
    $parent = Split-Path -Parent $DestPath
    if (!(Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if (Test-Path $DestPath) {
        Write-Host "Target already exists at $DestPath - skipping or updating" -ForegroundColor Yellow
        return
    }

    if ($Method -eq 'Link') {
        try {
            New-Item -ItemType Junction -Path $DestPath -Target $SourcePath -Force | Out-Null
            Write-Host "[OK] Linked (Junction): $DestPath -> $SourcePath" -ForegroundColor Green
        } catch {
            Write-Warning "Junction failed, falling back to Copy: $_"
            Copy-Item -Path $SourcePath -Destination $DestPath -Recurse -Force
            Write-Host "[OK] Copied to: $DestPath" -ForegroundColor Green
        }
    } else {
        Copy-Item -Path $SourcePath -Destination $DestPath -Recurse -Force
        Write-Host "[OK] Copied to: $DestPath" -ForegroundColor Green
    }
}

if ($Scope -eq 'Global') {
    Write-Host "`n=== Installing Globally for Current User ===" -ForegroundColor Cyan
    
    # 1. GitHub Copilot / Open Agent Skills standard (~/.agents/skills)
    $agentsGlobal = Join-Path $HOME ".agents\skills\puzzle-game-ui"
    Install-SkillDir -DestPath $agentsGlobal -SourcePath $sourceDir -Method $Method

    # 2. Claude Code global (~/.claude/skills)
    $claudeGlobal = Join-Path $HOME ".claude\skills\puzzle-game-ui"
    Install-SkillDir -DestPath $claudeGlobal -SourcePath $sourceDir -Method $Method

    # 3. OpenAI Codex global (~/.codex/skills)
    $codexGlobal = Join-Path $HOME ".codex\skills\puzzle-game-ui"
    Install-SkillDir -DestPath $codexGlobal -SourcePath $sourceDir -Method $Method

    Write-Host "`nGlobal setup completed! Available in:" -ForegroundColor Green
    Write-Host "  - GitHub Copilot (VS Code & CLI) -> $agentsGlobal"
    Write-Host "  - Claude Code (CLI / Desktop)    -> $claudeGlobal"
    Write-Host "  - OpenAI Codex CLI / Agent       -> $codexGlobal"
    Write-Host "  - Google Antigravity / Gemini    -> via ~/.agents/skills"
    Write-Host "  - Roo Code / Cline / OpenAgent   -> via ~/.agents/skills"
}
elseif ($Scope -eq 'Project') {
    if ([string]::IsNullOrWhiteSpace($TargetPath) -or !(Test-Path $TargetPath)) {
        Write-Error "Please specify a valid -TargetPath for Project scope."
        exit 1
    }

    $absTarget = (Resolve-Path $TargetPath).Path
    Write-Host "`n=== Installing into Project: $absTarget ===" -ForegroundColor Cyan

    # 1. .agents/skills (Copilot, OpenAgent, Codex)
    $projAgents = Join-Path $absTarget ".agents\skills\puzzle-game-ui"
    Install-SkillDir -DestPath $projAgents -SourcePath $sourceDir -Method $Method

    # 2. .claude/skills (Claude Code)
    $projClaude = Join-Path $absTarget ".claude\skills\puzzle-game-ui"
    Install-SkillDir -DestPath $projClaude -SourcePath $sourceDir -Method $Method

    # 3. Cursor rules (.cursor/rules/puzzle-game-ui.mdc)
    $cursorRulesDir = Join-Path $absTarget ".cursor\rules"
    if (!(Test-Path $cursorRulesDir)) { New-Item -ItemType Directory -Path $cursorRulesDir -Force | Out-Null }
    $cursorSrc = Join-Path $sourceDir "adapters\cursor\puzzle-game-ui.mdc"
    Copy-Item -Path $cursorSrc -Destination (Join-Path $cursorRulesDir "puzzle-game-ui.mdc") -Force
    Write-Host "[OK] Cursor rule installed at: $cursorRulesDir\puzzle-game-ui.mdc" -ForegroundColor Green

    # 4. Windsurf rules (.windsurfrules)
    $windsurfSrc = Join-Path $sourceDir "adapters\windsurf\.windsurfrules"
    $windsurfDest = Join-Path $absTarget ".windsurfrules"
    if (!(Test-Path $windsurfDest)) {
        Copy-Item -Path $windsurfSrc -Destination $windsurfDest -Force
        Write-Host "[OK] Windsurf rules created at: $windsurfDest" -ForegroundColor Green
    } else {
        Write-Host "[INFO] .windsurfrules already exists in project" -ForegroundColor Yellow
    }

    # 5. Gemini / Google Antigravity (GEMINI.md and .gemini/rules.md)
    $geminiDest = Join-Path $absTarget "GEMINI.md"
    if (!(Test-Path $geminiDest)) {
        Copy-Item -Path (Join-Path $sourceDir "adapters\gemini-antigravity\GEMINI.md") -Destination $geminiDest -Force
        Write-Host "[OK] Gemini/Antigravity GEMINI.md created at: $geminiDest" -ForegroundColor Green
    }
    $geminiDir = Join-Path $absTarget ".gemini"
    if (!(Test-Path $geminiDir)) { New-Item -ItemType Directory -Path $geminiDir -Force | Out-Null }
    Copy-Item -Path (Join-Path $sourceDir "adapters\gemini-antigravity\rules.md") -Destination (Join-Path $geminiDir "rules.md") -Force
    Write-Host "[OK] Gemini rules created at: $geminiDir\rules.md" -ForegroundColor Green

    # 6. Cline (.clinerules)
    $clineDest = Join-Path $absTarget ".clinerules"
    if (!(Test-Path $clineDest)) {
        Copy-Item -Path (Join-Path $sourceDir "adapters\cline\.clinerules") -Destination $clineDest -Force
        Write-Host "[OK] Cline rules created at: $clineDest" -ForegroundColor Green
    }

    # 7. Continue.dev (.continue/prompts/puzzle-game-ui.prompt)
    $continuePromptsDir = Join-Path $absTarget ".continue\prompts"
    if (!(Test-Path $continuePromptsDir)) { New-Item -ItemType Directory -Path $continuePromptsDir -Force | Out-Null }
    Copy-Item -Path (Join-Path $sourceDir "adapters\continue\puzzle-game-ui.prompt") -Destination (Join-Path $continuePromptsDir "puzzle-game-ui.prompt") -Force
    Write-Host "[OK] Continue.dev prompt installed at: $continuePromptsDir\puzzle-game-ui.prompt" -ForegroundColor Green

    Write-Host "`nProject setup completed for: $absTarget" -ForegroundColor Green
}
