<#
.SYNOPSIS
    Installs casual-game-kit (and puzzle-game-ui) skill globally or into a specific project for multiple IDEs/AI agents.
.PARAMETER Scope
    'Global' (default) installs into user-level directories (~/.agents/skills, ~/.claude/skills, ~/.codex/skills).
    'Project' installs into a specified repository.
.PARAMETER TargetPath
    Path to the target project directory (required when Scope is 'Project').
.PARAMETER Method
    'Auto' (default: Copy if remote/npx, Link if local git clone), 'Link', or 'Copy'.
#>
[CmdletBinding()]
param(
    [ValidateSet('Global', 'Project')]
    [string]$Scope = 'Global',

    [string]$TargetPath = '',

    [ValidateSet('Auto', 'Link', 'Copy')]
    [string]$Method = 'Auto'
)

# 1. Detect if running remotely (e.g. irm ... | iex) or locally
$isRemote = [string]::IsNullOrWhiteSpace($PSScriptRoot) -or !(Test-Path (Join-Path $PSScriptRoot "SKILL.md"))
$tempExtract = $null

if ($isRemote) {
    Write-Host "Remote installer mode detected. Fetching latest release from GitHub..." -ForegroundColor Cyan
    $tempZip = Join-Path $env:TEMP "casual-game-kit-$([guid]::NewGuid().ToString('N')).zip"
    $tempExtract = Join-Path $env:TEMP "casual-game-kit-$([guid]::NewGuid().ToString('N'))"
    
    $zipUrl = "https://github.com/qanh10x10/casual-game-kit/archive/refs/heads/main.zip"
    try {
        Invoke-RestMethod -Uri $zipUrl -OutFile $tempZip
        Expand-Archive -Path $tempZip -DestinationPath $tempExtract -Force
        Remove-Item -Force $tempZip -ErrorAction SilentlyContinue
        $sourceDir = Join-Path $tempExtract "casual-game-kit-main"
    } catch {
        Write-Error "Failed to download casual-game-kit from GitHub: $_"
        exit 1
    }
    if ($Method -eq 'Auto') {
        $Method = 'Copy'
    }
} else {
    $sourceDir = $PSScriptRoot
    if ($Method -eq 'Auto') {
        $Method = 'Link'
    }
}

Write-Host "Source skill directory: $sourceDir" -ForegroundColor Cyan

function Install-SkillDir {
    param([string]$DestPath, [string]$SourcePath, [string]$InstallMethod)
    
    $parent = Split-Path -Parent $DestPath
    if (!(Test-Path $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if (Test-Path $DestPath) {
        $item = Get-Item $DestPath -Force -ErrorAction SilentlyContinue
        if ($item.LinkType) {
            Remove-Item $DestPath -Force -Recurse -ErrorAction SilentlyContinue
        } elseif ($InstallMethod -eq 'Copy') {
            Copy-Item -Path "$SourcePath\*" -Destination $DestPath -Recurse -Force
            Write-Host "[OK] Updated files in: $DestPath" -ForegroundColor Green
            return
        } else {
            Remove-Item $DestPath -Force -Recurse -ErrorAction SilentlyContinue
        }
    }

    if ($InstallMethod -eq 'Link') {
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
        Write-Host "[OK] Copied permanently to: $DestPath" -ForegroundColor Green
    }
}

try {
    if ($Scope -eq 'Global') {
        Write-Host "`n=== Installing Globally for Current User ===" -ForegroundColor Cyan
        
        # 1. GitHub Copilot, Roo Code, OpenAgent standard (~/.agents/skills)
        $agentsGlobal = Join-Path $HOME ".agents\skills\casual-game-kit"
        Install-SkillDir -DestPath $agentsGlobal -SourcePath $sourceDir -InstallMethod $Method
        Install-SkillDir -DestPath (Join-Path $HOME ".agents\skills\puzzle-game-ui") -SourcePath $sourceDir -InstallMethod $Method

        # 2. Claude Code global (~/.claude/skills)
        $claudeGlobal = Join-Path $HOME ".claude\skills\casual-game-kit"
        Install-SkillDir -DestPath $claudeGlobal -SourcePath $sourceDir -InstallMethod $Method
        Install-SkillDir -DestPath (Join-Path $HOME ".claude\skills\puzzle-game-ui") -SourcePath $sourceDir -InstallMethod $Method

        # 3. OpenAI Codex global (~/.codex/skills)
        $codexGlobal = Join-Path $HOME ".codex\skills\casual-game-kit"
        Install-SkillDir -DestPath $codexGlobal -SourcePath $sourceDir -InstallMethod $Method
        Install-SkillDir -DestPath (Join-Path $HOME ".codex\skills\puzzle-game-ui") -SourcePath $sourceDir -InstallMethod $Method

        # 4. Optional: Configure npm allow-git = all if npm is present
        if (Get-Command npm -ErrorAction SilentlyContinue) {
            try {
                $curAllow = (npm config get allow-git 2>$null)
                if ($curAllow -is [string]) {
                    $curAllow = $curAllow.Trim()
                }
                if ($curAllow -eq 'none' -or [string]::IsNullOrWhiteSpace($curAllow)) {
                    npm config set allow-git all | Out-Null
                    Write-Host "[INFO] Configured npm allow-git = all (fixes Node 22+/npm 11+ git fetch restriction)" -ForegroundColor Cyan
                }
            } catch {}
        }

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
        $projAgents = Join-Path $absTarget ".agents\skills\casual-game-kit"
        Install-SkillDir -DestPath $projAgents -SourcePath $sourceDir -InstallMethod $Method

        # 2. .claude/skills (Claude Code)
        $projClaude = Join-Path $absTarget ".claude\skills\casual-game-kit"
        Install-SkillDir -DestPath $projClaude -SourcePath $sourceDir -InstallMethod $Method

        # 3. Cursor rules (.cursor/rules/casual-game-kit.mdc)
        $cursorRulesDir = Join-Path $absTarget ".cursor\rules"
        if (!(Test-Path $cursorRulesDir)) { New-Item -ItemType Directory -Path $cursorRulesDir -Force | Out-Null }
        $cursorSrc = Join-Path $sourceDir "adapters\cursor\casual-game-kit.mdc"
        Copy-Item -Path $cursorSrc -Destination (Join-Path $cursorRulesDir "casual-game-kit.mdc") -Force
        Write-Host "[OK] Cursor rule installed at: $cursorRulesDir\casual-game-kit.mdc" -ForegroundColor Green

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

        # 7. Continue.dev (.continue/prompts/casual-game-kit.prompt)
        $continuePromptsDir = Join-Path $absTarget ".continue\prompts"
        if (!(Test-Path $continuePromptsDir)) { New-Item -ItemType Directory -Path $continuePromptsDir -Force | Out-Null }
        Copy-Item -Path (Join-Path $sourceDir "adapters\continue\casual-game-kit.prompt") -Destination (Join-Path $continuePromptsDir "casual-game-kit.prompt") -Force
        Write-Host "[OK] Continue.dev prompt installed at: $continuePromptsDir\casual-game-kit.prompt" -ForegroundColor Green

        Write-Host "`nProject setup completed for: $absTarget" -ForegroundColor Green
    }
} finally {
    if ($tempExtract -and (Test-Path $tempExtract)) {
        Remove-Item -Recurse -Force $tempExtract -ErrorAction SilentlyContinue
    }
}
