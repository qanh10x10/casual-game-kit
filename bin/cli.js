#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync } = require('child_process');

const rootDir = path.resolve(__dirname, '..');

const args = process.argv.slice(2);
const isHelp = args.includes('--help') || args.includes('-h') || args.includes('help');
const isGlobalOnly = args.includes('--global') || args.includes('-g');
const projectFlagIdx = args.findIndex(a => a === '--project' || a === '-p');
const customProjectPath = projectFlagIdx !== -1 && args[projectFlagIdx + 1] ? args[projectFlagIdx + 1] : null;

if (isHelp) {
  console.log(`
Casual Game Kit - Agent Skill Installer
Usage:
  npx casual-game-kit [command] [options]
  npx puzzle-game-kit [command] [options]

Options:
  --global, -g         Install globally for current user (Copilot, Claude, Codex)
  --project, -p <dir>  Install into specific project directory (Cursor, Windsurf, Gemini, etc.)
  --help, -h           Show this help message

Examples:
  npx casual-game-kit                Auto-install (Global + Project if in a project dir)
  npx casual-game-kit --global       Install globally across all IDEs on your machine
  npx casual-game-kit -p ./MyProject Install into specific project
`);
  process.exit(0);
}

function log(msg, color = '\x1b[32m') {
  console.log(`${color}${msg}\x1b[0m`);
}

function warn(msg) {
  console.log(`\x1b[33m${msg}\x1b[0m`);
}

function linkOrCopy(src, dest) {
  const parent = path.dirname(dest);
  if (!fs.existsSync(parent)) {
    fs.mkdirSync(parent, { recursive: true });
  }

  if (fs.existsSync(dest)) {
    warn(`  [SKIP] Already exists: ${dest}`);
    return;
  }

  try {
    if (process.platform === 'win32') {
      // Use directory junction on Windows (does not require admin privileges)
      fs.symlinkSync(src, dest, 'junction');
    } else {
      fs.symlinkSync(src, dest, 'dir');
    }
    log(`  [LINK] ${dest} -> ${src}`);
  } catch (err) {
    warn(`  [COPY] Link failed (${err.message}), falling back to copy.`);
    fs.cpSync(src, dest, { recursive: true });
    log(`  [COPY] Copied to ${dest}`);
  }
}

function copyFileSafe(src, dest) {
  const parent = path.dirname(dest);
  if (!fs.existsSync(parent)) {
    fs.mkdirSync(parent, { recursive: true });
  }
  fs.copyFileSync(src, dest);
  log(`  [FILE] ${dest}`);
}

function installGlobal() {
  log('\n=== Installing Globally for Current User ===', '\x1b[36m');
  const home = os.homedir();

  // 1. GitHub Copilot, Roo Code, OpenAgent (~/.agents/skills)
  const agentsDir = path.join(home, '.agents', 'skills', 'casual-game-kit');
  linkOrCopy(rootDir, agentsDir);
  // Also link legacy puzzle-game-ui alias
  linkOrCopy(rootDir, path.join(home, '.agents', 'skills', 'puzzle-game-ui'));

  // 2. Claude Code CLI / Desktop (~/.claude/skills)
  const claudeDir = path.join(home, '.claude', 'skills', 'casual-game-kit');
  linkOrCopy(rootDir, claudeDir);
  linkOrCopy(rootDir, path.join(home, '.claude', 'skills', 'puzzle-game-ui'));

  // 3. OpenAI Codex CLI / Agent (~/.codex/skills)
  const codexDir = path.join(home, '.codex', 'skills', 'casual-game-kit');
  linkOrCopy(rootDir, codexDir);
  linkOrCopy(rootDir, path.join(home, '.codex', 'skills', 'puzzle-game-ui'));

  log('\nGlobal skills active in:');
  console.log('  - GitHub Copilot (VS Code & CLI)');
  console.log('  - Claude Code');
  console.log('  - OpenAI Codex');
  console.log('  - Google Antigravity & OpenAgent (via ~/.agents/skills)');
}

function installProject(projectPath) {
  const absTarget = path.resolve(projectPath);
  log(`\n=== Installing into Project: ${absTarget} ===`, '\x1b[36m');

  // 1. .agents/skills (Copilot, Codex, OpenAgent)
  linkOrCopy(rootDir, path.join(absTarget, '.agents', 'skills', 'casual-game-kit'));

  // 2. .claude/skills (Claude Code)
  linkOrCopy(rootDir, path.join(absTarget, '.claude', 'skills', 'casual-game-kit'));

  // 3. Cursor rules (.cursor/rules/casual-game-kit.mdc)
  copyFileSafe(
    path.join(rootDir, 'adapters', 'cursor', 'casual-game-kit.mdc'),
    path.join(absTarget, '.cursor', 'rules', 'casual-game-kit.mdc')
  );

  // 4. Windsurf rules (.windsurfrules)
  const windsurfDest = path.join(absTarget, '.windsurfrules');
  if (!fs.existsSync(windsurfDest)) {
    copyFileSafe(path.join(rootDir, 'adapters', 'windsurf', '.windsurfrules'), windsurfDest);
  } else {
    warn(`  [SKIP] .windsurfrules already exists at ${windsurfDest}`);
  }

  // 5. Google Antigravity & Gemini CLI (GEMINI.md & .gemini/rules.md)
  const geminiMd = path.join(absTarget, 'GEMINI.md');
  if (!fs.existsSync(geminiMd)) {
    copyFileSafe(path.join(rootDir, 'adapters', 'gemini-antigravity', 'GEMINI.md'), geminiMd);
  }
  copyFileSafe(
    path.join(rootDir, 'adapters', 'gemini-antigravity', 'rules.md'),
    path.join(absTarget, '.gemini', 'rules.md')
  );

  // 6. Cline (.clinerules)
  const clineDest = path.join(absTarget, '.clinerules');
  if (!fs.existsSync(clineDest)) {
    copyFileSafe(path.join(rootDir, 'adapters', 'cline', '.clinerules'), clineDest);
  }

  // 7. Continue.dev (.continue/prompts/casual-game-kit.prompt)
  copyFileSafe(
    path.join(rootDir, 'adapters', 'continue', 'casual-game-kit.prompt'),
    path.join(absTarget, '.continue', 'prompts', 'casual-game-kit.prompt')
  );

  log(`\nProject setup complete for: ${absTarget}!`);
}

// Execution logic
const currentDir = process.cwd();
const isInsideProject = fs.existsSync(path.join(currentDir, 'Assets')) ||
                        fs.existsSync(path.join(currentDir, '.git')) ||
                        fs.existsSync(path.join(currentDir, 'package.json'));

if (customProjectPath) {
  installProject(customProjectPath);
} else if (isGlobalOnly) {
  installGlobal();
} else {
  // Default auto behavior
  installGlobal();
  if (isInsideProject && currentDir !== rootDir) {
    installProject(currentDir);
  }
}
