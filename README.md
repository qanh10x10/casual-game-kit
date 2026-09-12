# Casual Game Kit (Unity UI)

Bộ skill AI đa nền tảng chuyên biệt cho thiết kế, audit và xây dựng UI Unity Casual & Puzzle Game (Home, HUD, Daily Reward, Quests, Shop, Popups) theo chuẩn mở **Agent Skills**.

Hỗ trợ đồng thời:
- **GitHub Copilot** (VS Code, Visual Studio, Copilot CLI)
- **Claude Code** (Anthropic CLI / Desktop)
- **OpenAI Codex** (Codex CLI / OpenAgent)
- **Google Antigravity & Gemini CLI**
- **Cursor**
- **Windsurf** (Cascade)
- **Cline & Roo Code**
- **Continue.dev**

Repository: [https://github.com/qanh10x10/casual-game-kit.git](https://github.com/qanh10x10/casual-game-kit.git)

---

## 1. Cấu trúc thư mục

```text
casual-game-kit/
├── SKILL.md                          # Đặc tả skill chuẩn Agent Skills
├── bin/cli.js                        # Node CLI installer (0 dependencies)
├── package.json                      # npm package config
├── agents/
│   └── openai.yaml                   # Model/runtime config
├── references/                       # 11 tài liệu blueprint chi tiết
│   ├── ai-spec-template.md           # Template hợp đồng UI (Surface Contract)
│   ├── data-and-assets-blueprint.md  # ScriptableObject, CSV, runtime state
│   ├── data-contracts.md             # Tiền tệ, quest, reward schemas
│   ├── framework.md                  # Giới hạn kiến trúc và code boundary
│   ├── project-audit.md              # File mẫu audit
│   ├── ugui-layout-blueprint.md      # Layout 1080x1920, SafeArea, ScrollRect
│   ├── ui-manager-blueprint.md       # Root prefab UIManager
│   ├── ui-popup-script-contracts.md  # Popup controller & item contracts
│   ├── unity-mcp-workflow.md         # Quy trình phối hợp Unity MCP
│   ├── ux-surfaces.md                # Recipe cho từng màn hình
│   └── validation.md                 # Bộ tiêu chí nghiệm thu
├── adapters/                         # Adapter cho từng IDE/Agent
│   ├── cursor/casual-game-kit.mdc    # Rule cho Cursor (.cursor/rules/)
│   ├── windsurf/.windsurfrules       # Rule cho Windsurf
│   ├── gemini-antigravity/           # GEMINI.md & rules.md cho Gemini / Antigravity
│   ├── cline/.clinerules             # Rule cho Cline
│   ├── continue/casual-game-kit.prompt # Slash command / prompt cho Continue.dev
│   ├── codex/AGENTS-snippet.md       # Snippet cho AGENTS.md (OpenAI Codex)
│   ├── copilot/instructions-snippet.md # Snippet cho .github/copilot-instructions.md
│   └── claude/CLAUDE-snippet.md      # Snippet cho CLAUDE.md
├── install.ps1                       # Script cài đặt tự động (Windows)
├── install.sh                        # Script cài đặt tự động (Linux/macOS)
└── README.md
```

---

## 2. Cách cài đặt nhanh nhất bằng NPX (Khuyên dùng)

Bộ skill đã được tích hợp sẵn CLI Node.js không phụ thuộc thư viện ngoài (0 dependencies), chạy trực tiếp bằng lệnh:

```bash
# Từ xa không cần clone repo:
npx github:qanh10x10/casual-game-kit --global

# Hoặc sau khi clone:
npx casual-game-kit --global
```

### Các tùy chọn npx:
- **Cài đặt toàn cục cho mọi dự án (User Global):**
  ```bash
  npx casual-game-kit --global
  ```
  -> Tự động tạo symbolic/junction link vào `~/.agents/skills/`, `~/.claude/skills/`, `~/.codex/skills/`.

- **Cài đặt trực tiếp vào thư mục dự án Unity hiện tại:**
  ```bash
  npx casual-game-kit
  ```
  -> Nếu bạn đang đứng trong thư mục dự án (có `Assets/`), CLI sẽ tự động thiết lập cả Global và Project adapters (Cursor `.mdc`, Windsurf `.windsurfrules`, Gemini `GEMINI.md`, Cline `.clinerules`, Continue `.prompt`).

- **Cài vào một thư mục dự án cụ thể:**
  ```bash
  npx casual-game-kit -p D:/Projects/MyUnityGame
  ```

---

## 3. Cài đặt bằng Script (Nếu không dùng Node.js)

### Cách A: Cài đặt Toàn cục (PowerShell)
```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\Admin\Documents\GitHub\puzzle-game-ui\install.ps1" -Scope Global
```

### Cách B: Cài đặt Vào Một Dự Án Cụ Thể (PowerShell)
```powershell
powershell -ExecutionPolicy Bypass -File "C:\Users\Admin\Documents\GitHub\puzzle-game-ui\install.ps1" -Scope Project -TargetPath "D:\Projects\MyGame"
```

---

## 3. Hướng dẫn sử dụng theo từng nền tảng

### 1. GitHub Copilot (VS Code / CLI)
- Gõ: `@puzzle-game-ui lập contract cho màn hình Home`

### 2. OpenAI Codex (CLI / Agent)
- Codex tự động nạp từ `~/.codex/skills/puzzle-game-ui/SKILL.md` hoặc `.agents/skills/`.
- Gọi prompt liên quan đến Unity UI hoặc puzzle game UI.

### 3. Claude Code (CLI / Desktop)
- Chạy `claude`, gõ: `Review UI theo skill puzzle-game-ui`.

### 4. Google Antigravity & Gemini CLI
- Antigravity tự nạp từ `GEMINI.md` / `.gemini/rules.md` trong workspace và `~/.agents/skills`.

### 5. Cursor
- Tự động kích hoạt khi chỉnh sửa các file Unity UI qua rule `.cursor/rules/puzzle-game-ui.mdc`.

### 6. Windsurf / Cline / Continue.dev
- Tuân thủ cấu trúc Surface Contract và các blueprint thông qua file rules tương ứng.

---

## 4. Quy ước cốt lõi của Skill

Mọi tác vụ UI đều phải tạo **Surface Contract** trước khi sinh code hoặc sửa prefab:
```text
surface -> user job -> states -> actions -> data source -> hierarchy -> bindings
        -> owner -> persistence -> events -> validation evidence
```
1. **Definitions vs State**: ScriptableObject/CSV là định nghĩa dữ liệu (read-only lúc runtime). Tiến trình người chơi, tiền tệ phải lưu ở runtime state model riêng.
2. **Idempotent Claims**: Kiểm tra điều kiện -> cộng thưởng một lần -> lưu dữ liệu -> bắn sự kiện cập nhật UI.
3. **Hierarchy chuẩn**: `Screen` -> `SafeArea` -> `Header`, `Content`, `Footer`, `Overlay`.
