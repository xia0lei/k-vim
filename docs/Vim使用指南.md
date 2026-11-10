# Vim 使用指南

> 状态：参考
>
> 最后核对：2026-11-10
>
> 配置入口：`~/.vimrc`、`~/.vim/after/plugin/local.vim`、`~/.config/coc/coc-settings.json`

本文记录 k-vim 的通用配置、插件、主题和常用操作，不绑定具体项目。Lua/Skynet 示例只用于说明工作流，实际项目可按相同方式配置 `.luarc.json` 和测试命令。

## 1. 当前配置结构

当前 Vim 使用 k-vim 配置，并通过软链接指向仓库目录：

| 路径 | 作用 |
|---|---|
| `~/.vimrc` → `<repo>/vimrc` | 主配置：基础设置、快捷键、主题 |
| `~/.vimrc.bundles` → `<repo>/vimrc.bundles` | vim-plug 插件清单和插件配置 |
| `~/.vim` → `<repo>/` | 运行时目录和插件目录 |
| `~/.vim/after/plugin/local.vim` | 通用本地 overlay，在 k-vim 和插件之后加载 |
| `~/.config/coc/coc-settings.json` → `<repo>/coc-settings.json` | coc.nvim 全局设置 |
| `<repo>/scripts/link-coc-settings.sh` | 创建上面的 coc 设置软链接 |
| `.luarc.json`（项目根目录，可选） | LuaLS/Lua Language Server 项目配置 |

新机器初始化：

```bash
git clone git@github.com:xia0lei/k-vim.git
cd k-vim
./install.sh --for-vim
# install.sh 会安装 vim-plug 插件、链接 coc 设置并安装 coc 扩展
```

如果自动安装失败，可手动执行：

```bash
<repo>/scripts/install-coc-extensions.sh
```

或在 Vim 中执行：

```vim
:CocInstall coc-clangd coc-css coc-json coc-lua coc-go coc-pyright
```

`~/.config/nvim/init.lua` 是未使用的 Neovim 配置；以下内容均针对 Vim 9.2。

## 2. 技术栈支持

| 语言/文件 | 能力 | 当前工具 |
|---|---|---|
| Lua / Skynet | 语法、LSP、诊断、跳转、引用、重命名 | `vim-lua`、coc-lua（自带 LuaLS 3.18.2-dev）、项目根目录 `.luarc.json`（可选） |
| Python | LSP、诊断、flake8、yapf | coc-pyright（扩展自带 pyright）、`flake8`、`yapf` |
| Shell | 语法、shellcheck（安装后生效） | Vim 内置 sh 语法、ALE + `shellcheck`（需安装） |
| Markdown | 语法、折行、跳转 | vim-markdown |
| Protocol Buffers | 语法 | vim-protobuf |
| Go | LSP、诊断、格式化 | coc-go、`gopls`、vim-go、`gofmt`（`goimports` 未安装时自动回退） |
| JSON / CSS / C/C++ | LSP、诊断 | coc-json、coc-css、coc-clangd + `clangd` |
| 搜索 | 文件、内容、符号 | `rg`、CtrlP、CtrlSF、coc list |

LuaLS 支持到 Lua 5.4。如果项目自带 `skynet/3rd/lua/luac`，`:LuaCheck` 会优先使用该编译器，找不到时才回退到系统 `luac`；可通过 `g:lua_check_compiler` 或 `b:lua_check_compiler` 强制指定。

## 3. 首次检查

```bash
vim --version | head -5
lua-language-server --version
node --version
```

当前 Vim 是 9.2，带 `+lua`（Lua 5.4.4）、`+python3`、`+job`、`+timers` 和 `+terminal`。Lua 5.4.4 编译安装在 `/opt/lua-5.4.4`，`vim --version` 应显示 `+lua`。可以运行 Vim 兼容的 Lua 插件，但 Neovim 专用 Lua 插件仍不能直接使用。

在项目根目录打开 Vim，确认 Coc 已启动：

```bash
cd ~/your-project
vim .
```

```vim
:CocInfo
:CocList extensions
:CocCommand lua.version
```

`CocInfo` 应能看到 `coc-lua`、`coc-pyright`、`coc-go` 等扩展，`lua.version` 应返回 LuaLS 版本。若没有启动，执行 `:CocStart` 或 `:CocRestart`。

## 4. 常用快捷键

k-vim 原有的 `,` 是 leader。以下只列高频操作。

| 快捷键 | 作用 |
|---|---|
| `,w` / `,q` | 保存 / 退出 |
| `,p` | CtrlP 文件搜索（已用 rg 作为文件源） |
| `,f` | 项目内最近文件 MRU |
| `,fu` / `,fU` | CtrlPFunky 函数搜索 / 光标下单词搜索 |
| `\` | CtrlSF 全文搜索（自动使用 rg 后端） |
| `,gg` | `:grep` 全文搜索，输入 pattern 后回车；结果进入 quickfix |
| `,jd` | 跳转到定义（横向分屏） |
| `,gy` / `,gi` | 类型定义 / 实现 |
| `,gr` | 查找引用 |
| `,rn` | 重命名符号 |
| `K` | 悬浮文档 |
| `[g` / `]g` | 上一个 / 下一个 coc 诊断 |
| `,lc` | 当前 Lua 文件执行 `:LuaCheck` |
| `,tc` | 打开主题选择器；`:Theme <name>` 直接切换 |
| `,sl` | 重新加载本地 overlay（不重启 Vim） |
| `,ac` / `,ax` | 打开 Claude Code / Codex 终端分屏 |
| `,aC` / `,aR` / `,aX` | 继续 Claude / 选择 Claude 会话 / 继续 Codex 会话 |
| `,ep` / `,en` | 上一个 / 下一个 ALE 问题 |
| `,ec` | 开关 ALE |
| `,ev` | 编辑 `$MYVIMRC` |
| `,ss` | 重新加载 `$MYVIMRC` |
| `,zz` | 折叠全部 / 展开全部 |
| `,h` | 打开/关闭 Gundo 历史 |
| `,ge` | `:Gdiff` 当前文件 |
| `,a` | EasyAlign 对齐 |
| `,y` | Python 文件用 yapf 格式化 |
| `kj` | 插入模式下代替 Esc |
| `[b` / `]b` | 上一个 / 下一个 buffer |
| `F2` / `F3` / `F4` / `F6` | 行号 / 可打印字符 / 换行 / 语法高亮开关 |
| `F9` | Tagbar（需要 ctags；未安装时会提示） |

## 5. Lua / Skynet 开发流程

1. 从项目根目录打开文件，确保项目自带的 `.luarc.json`（如有）被识别：

```bash
cd ~/your-project
vim path/to/file.lua
```

2. 等待 Coc 诊断。`[g` / `]g` 在诊断间跳转，`:CocDiagnostics` 打开问题列表。
3. 用 `,jd` 横向分屏跳转定义、`,gr` 查引用、`,rn` 重命名、`K` 查看文档。
4. 保存前执行 `:LuaCheck` 或 `,lc`。该命令优先使用项目内的 `skynet/3rd/lua/luac`，找不到时回退系统 `luac -p`。通过时提示“Lua 语法检查通过”，失败时显示编译器原始错误。

5. 运行项目测试，例如：

```vim
:terminal <your-test-command>
```

6. 只改一个文件时，也可以直接：

```bash
luac -p path/to/file.lua
```

LuaLS 会读取项目根的 `.luarc.json`（如果项目提供），其中可配置 `runtime.path`、项目全局变量和忽略目录。不要把项目规则复制到全局 `coc-settings.json`，避免两份配置漂移。

## 6. 搜索与导航

| 场景 | 命令 |
|---|---|
| 按文件名查找 | `,p` 或 `:CtrlP` |
| 显式指定项目根 | `:CtrlPProject` |
| 项目内最近文件 | `,f` |
| 当前文件函数 | `,fu` |
| 全项目内容搜索 | `\`（CtrlSF）或 `,gg`（`:grep`） |
| 当前 buffer 符号 | `:CocList symbols` |
| 诊断列表 | `:CocDiagnostics` |
| quickfix 下一个/上一个 | `:cnext` / `:cprev` |
| 打开 quickfix | `:copen` |

`:grep` 已配置为 `rg --vimgrep --smart-case --hidden -g "!.git/*"`，结果格式为 `file:line:col:message`，可以直接在 quickfix 中跳转。CtrlP 也使用 `rg --files`，会遵循 `.gitignore`。

`,f` 是项目内 MRU，`,p` 是项目文件搜索。两者以当前文件的 git 根目录为范围；当前文件不在 git 仓库内时回退当前目录，部署目录不会进入项目搜索范围。需要显式指定项目根时使用 `:CtrlPProject`。

CtrlP 默认会排除当前打开的文件；overlay 已设置 `g:ctrlp_match_current_file = 1`，所以打开 `msgagent.lua` 后再按 `,p` 仍然能看到它。

## 7. Python、Shell、Markdown、Proto、Go

### Python

- coc-pyright 扩展自带 pyright，不需要单独安装 `pyright` 命令。
- ALE 使用 `flake8`；需要安装 `flake8`。
- `<leader>y` 使用 `yapf` 格式化 Python 文件；需要安装 `yapf`。

### Shell

- Vim 内置 sh 语法。
- ALE 已配置 `shellcheck`，安装后自动生效。
- Shell 文件在 overlay 中使用 4 空格缩进。

### Markdown

- vim-markdown 提供语法和导航。
- Markdown 文件自动使用 `wrap`、`linebreak`，不显示 list 字符。
- 需要 lint 时安装 markdownlint 后手动运行。

### Protocol Buffers

- vim-protobuf 提供语法高亮。
- 协议生成按项目自己的协议生成流程执行。

### Go

- coc-go 使用 `gopls`，需要安装 `gopls`。
- vim-go 的格式化命令优先使用 `goimports`；未安装时 overlay 自动回退到 `gofmt`。
- 需要 `goimports` 时执行：

```bash
go install golang.org/x/tools/cmd/goimports@latest
```

## 8. 配置维护

### 8.1 修改本地 overlay

本地通用配置放在：

```text
~/.vim/after/plugin/local.vim
```

它通过 `~/.vim` 软链接实际位于 `<repo>/after/plugin/local.vim`，在 k-vim 主配置和插件之后加载。

`after/plugin` 是全局加载的，不对应单个项目。项目相关规则应放在项目自己的 `.luarc.json` 或 `exrc` 中，不要写进全局 overlay。`:LuaCheck` 会优先使用项目内 `skynet/3rd/lua/luac`，找不到才回退 `luac`；需要强制指定编译器时设置：

```vim
let g:lua_check_compiler = 'luac'          " 全局
let b:lua_check_compiler = '/path/to/luac' " 当前 buffer
```

修改后不必重启 Vim：

```vim
:ReloadLocal
```

或按 `,sl`。不要把本地设置直接写进 `vimrc` 或 `vimrc.bundles`；`local.vim` 已随 k-vim 仓库提交，修改后提交到 k-vim 即可。

### 8.2 coc 设置

仓库内文件：

```text
<repo>/coc-settings.json
```

通过脚本链接到 coc 默认路径：

```bash
<repo>/scripts/link-coc-settings.sh
```

脚本会创建 `~/.config/coc/coc-settings.json` 软链接；如果目标已存在且不是该软链接，会先备份为 `coc-settings.json.bak.<时间戳>`。`install.sh --for-vim` 会自动调用该脚本。

当前只设置根目录识别、关闭扩展自动更新检查，并启用当前行诊断检查；没有配置保存时自动格式化。Lua 项目规则由项目自己的 `.luarc.json` 提供。

### 8.3 插件管理

```vim
:PlugStatus
:PlugInstall
:PlugUpdate
:PlugClean
```

coc 扩展可单独安装：

```bash
<repo>/scripts/install-coc-extensions.sh
```

该脚本通过 npm 安装与 `:CocInstall` 相同的扩展；Node 20 环境会自动选择兼容的 `coc-css@2.1.0`。自动安装失败时，可在 Vim 中手动执行 `:CocInstall coc-clangd coc-css coc-json coc-lua coc-go coc-pyright`。

Vim 已启用 `+lua`（Lua 5.4.4），可以运行 Vim 兼容的 Lua 插件；Neovim 专用插件仍不能直接使用。

### 8.4 主题

已通过 vim-plug 安装以下经典 Vim 主题（均为 Vimscript，支持 Vim 8+）：

| 主题 | 切换命令 | 风格 |
|---|---|---|
| gruvbox | `:Theme gruvbox` | 复古暖色深色 |
| dracula | `:Theme dracula` | 高对比紫黑 |
| nord | `:Theme nord` | 冷色蓝灰 |
| onedark | `:Theme onedark` | Atom One Dark |
| everforest | `:Theme everforest` | 柔和森林绿 |
| catppuccin | `:Theme catppuccin_mocha` | Catppuccin，另有 frappe/latte/macchiato |
| molokai | `:Theme molokai` | k-vim 原默认主题 |
| solarized | `:Theme solarized` | 原有 Solarized 主题 |

使用方式：

```vim
:Theme gruvbox
```

或按 `,tc` 打开主题选择器，输入序号后回车；`:Theme ` 后按 Tab 也可以补全主题名。

overlay 已启用 `termguicolors`；如果终端不支持真彩色，可临时 `:set notermguicolors` 并使用 256 色主题。`Airline` 状态栏会在主题自带 airline 配色时自动同步。

Catppuccin 的 `VertSplit` 最佳显示需要 Vim patch `9.2.349`；当前 Vim 包含补丁 1–271，只影响分隔线细节，不影响使用。主题插件位于 `vimrc.bundles` 的 Themes 段，更新用 `:PlugUpdate`。

### 8.5 不重启 Vim 重载

| 改动 | 重载方式 |
|---|---|
| 修改 `~/.vim/after/plugin/local.vim` | `:ReloadLocal` 或 `,sl` |
| 切换已安装主题 | `:Theme <name>` 或 `,tc` |
| 新增或修改 `vimrc.bundles` 里的 `Plug` | `:source $MYVIMRC`，再执行 `:PlugInstall` |
| 已安装但当前会话找不到主题 | `:set rtp+=~/.vim/bundle/<目录>`，再 `:colorscheme <name>` |
| 普通插件升级或新增 | 最稳妥是重启 Vim；Vim 没有通用的插件热重载 |

注意：

- `:PlugInstall` 只处理启动时已经登记的 `g:plugs`。如果刚刚往 `vimrc.bundles` 里新增了 `Plug`，先 `:source $MYVIMRC` 重新读取插件清单，再 `:PlugInstall`。
- 重新 source `vimrc` 可能重复执行部分插件配置。遇到重映射、重复定时器或异常时，直接重启 Vim。
- `,tc` 没反应时，先确认当前会话是否加载了 overlay：

```vim
:command Theme
:verbose map ,tc
```

如果 `:Theme` 不存在，执行：

```vim
:source ~/.vim/after/plugin/local.vim
```

## 9. 可选工具安装

以下工具不是必需，安装属于外部环境变更，按需执行：

```bash
# Shell lint
dnf install -y shellcheck

# Tagbar 的 ctags；优先 universal-ctags
dnf install -y ctags

# Markdown lint
npm install -g markdownlint-cli

# Go import 整理
go install golang.org/x/tools/cmd/goimports@latest
```

`stylua` 当前未安装，因此没有配置保存时自动格式化。需要时从 GitHub Release 安装，或使用 `cargo install stylua`；安装后可手动执行：

```bash
stylua path/to/file.lua
```

不要在未确认格式范围前对整仓执行 `stylua .`，避免产生与当前任务无关的格式化 diff。

## 10. Claude Code / Codex 集成

### 10.1 终端分屏（已配置）

overlay 提供两个轻量入口，Agent 会以 git 根目录作为工作目录启动：

| 命令 | 快捷键 | 作用 |
|---|---|---|
| `:ClaudeTerm` | `,ac` | 打开 Claude Code 终端 |
| `:ClaudeContinue` | `,aC` | 打开 Claude Code 并继续最近会话 |
| `:ClaudeResume` | `,aR` | 打开 Claude Code 会话选择器 |
| `:CodexTerm` | `,ax` | 打开 Codex 终端 |
| `:CodexResume` | `,aX` | 打开 Codex 并继续最近会话 |

- 再次执行同一命令会切回已有的 Agent 窗口，不会重复开新窗口。
- 终端模式下用 `Ctrl-\ Ctrl-N` 返回 Vim；这些 Agent 终端另外映射了 `<C-q>`。
- 终端普通模式下 `<C-q>` 关闭当前 Agent 窗口。
- overlay 在 `FocusGained` / `BufEnter` 时执行 `checktime`，配合 k-vim 的 `autoread`，可以重新加载 Agent 修改过的文件；有未保存修改时仍按 Vim 的提示处理。

长会话建议用 tmux 把 Vim 和 Agent 放在不同 pane。如果 shell 里的 `tmux` 别名异常，脚本或命令中可直接使用 `/usr/bin/tmux`，或先修复该别名。

### 10.2 Codex 内置 Vim 模式

Codex CLI 0.167.0 的 TUI composer 内置 Vim 模式。在 Codex 中输入：

```text
/vim
```

即可切换。若希望默认启用，在 `~/.codex/config.toml` 增加：

```toml
[tui]
vim_mode_default = true
```

该模式只控制 Codex 输入框的编辑方式，不控制 Vim 里的代码 buffer。键位可用 `/keymap` 查看；若当前版本的配置键不可用，保留默认并用 `/vim` 手动切换。

### 10.3 可选：vim-claude-code 插件

[`vim-claude-code`](https://github.com/rishi-opensource/vim-claude-code) 是社区维护的经典 Vim 插件，使用 Vimscript，要求 Vim 8+ 和 `+terminal`，不依赖 `+lua`。它提供：

- `<C-\>` 切换 Claude 终端；
- 可视选区或当前函数的上下文；
- 22 个子命令（explain、fix、test、review、commit 等）；
- 修改前的 diff 预览和 buffer 自动刷新。

安装方式（先确认后再执行）：

```vim
" 在 vimrc.bundles 的 plug#end() 之前加入
Plug 'rishi-opensource/vim-claude-code', { 'tag': 'v1.4.1' }
```

```vim
:PlugInstall
:Claude doctor
```

该插件默认映射 `<C-\>` 和 `<Leader>c*`；本仓库 overlay 使用 `,ac` / `,ax`，不冲突。它是第三方插件，安装前应自行审查来源并固定版本；当前未自动安装。diff 预览需要 Python3，当前已具备。

该插件只封装 Claude Code，不封装 Codex；Codex 使用上面的终端分屏或内置 `/vim`。

### 10.4 使用边界

- Agent 在 git 根目录启动，会读取项目的 `AGENTS.md`、`CLAUDE.md` 和当前代码。
- 在提示中直接写文件路径和行号，例如 `path/to/file.lua:120`，比粘贴大段代码更可靠。
- Agent 修改文件后用 `,ge` 查看 `:Gdiff`，或用 `git diff` 复核；不要假定 `autoread` 已覆盖所有修改。
- 不要在共享环境使用 `--dangerously-skip-permissions` 或 `--dangerously-bypass-approvals-and-sandbox`；保持正常确认和沙箱。
- 两个 Agent 都会受各自的项目规则和权限模式约束，不要在 Vim 配置里另写一套业务规则。

## 11. 常见问题

### 打开文件后 `,p` 看不到当前文件

CtrlP 默认排除当前打开的文件。overlay 已设置 `g:ctrlp_match_current_file = 1`；如果仍然看不到，执行 `:ReloadLocal` 或重启 Vim，再检查 `:echo g:ctrlp_match_current_file` 是否为 1。

### `,f` 里还出现部署目录

`,f` 现在是项目内 MRU。overlay 会在打开前把窗口 cwd 切到当前文件的 git 根；如果仍出现部署目录，执行 `:ReloadLocal` 或重启 Vim，并用 `:pwd`、`:verbose map ,f` 确认当前文件位于项目内。MRU 缓存本身不会删除，只是按项目过滤。

### `,tc` 没有反应

当前 Vim 会话是在 `local.vim` 创建或修改之前启动的，`after/plugin` 只会在启动时加载。执行一次：

```vim
:source ~/.vim/after/plugin/local.vim
```

之后 `,tc` 即可打开主题选择器。用 `:command Theme` 和 `:verbose map ,tc` 确认命令和映射是否存在；主题刚安装但当前会话找不到时，参考 8.5 节重新加载 runtimepath。

### Coc 没有启动

```vim
:CocInfo
:CocOpenLog
:CocRestart
```

同时检查 `node --version`（当前 v20）和 `~/.config/coc/extensions/package.json`。

### Lua 没有诊断或跳转

- `:pwd` 必须是项目根目录（包含 `.git` 或 `.luarc.json`），或当前文件位于该项目下。
- coc-lua 默认使用自带 LuaLS：`~/.config/coc/extensions/coc-lua-data/lua-language-server`；系统 PATH 也有 `/root/.local/bin/lua-language-server`。执行 `:CocCommand lua.version` 查看扩展和 LuaLS 版本。
- `:CocRestart` 后重新打开 Lua 文件。
- 检查项目根 `.luarc.json` 是否存在且 JSON 有效。

### `:LuaCheck` 使用了错误的 Lua 版本

`:LuaCheck` 优先查找当前 git 根目录下的 `skynet/3rd/lua/luac`，找不到才使用系统 `luac`。如果文件不在 git 仓库内，会从当前工作目录查找。

### F9 提示需要 ctags

tagbar 依赖 ctags；需要安装 universal-ctags，或忽略该提示，改用 coc 的定义/引用/符号列表。

### 搜索很慢或结果太多

- `,gg` 已限制到 git 仓库并使用 `rg`，会遵循 `.gitignore`。
- CtrlP 文件源也使用 `rg --files`。
- 如果搜索包含生成目录，检查 `.gitignore` 和 `.luarc.json` 的忽略目录，不要直接在 `rg` 命令里扩大范围。

### Neovim 配置要不要改

k-vim 同时支持 Neovim，但本文只覆盖 Vim。使用 Neovim 时需要单独验证 `init.vim`、LSP 和插件配置。

## 12. 关联文档

- [k-vim README](../README.md)：安装步骤和插件清单。
- [k-vim 说明](../k-vim.md)：常用快捷键和配置说明。
- [vim-plug](https://github.com/junegunn/vim-plug)：插件管理。
- [coc.nvim](https://github.com/neoclide/coc.nvim)：LSP 与补全。
- [vim-claude-code](https://github.com/rishi-opensource/vim-claude-code)：可选的 Claude Code 集成。
- [OpenAI Codex CLI](https://github.com/openai/codex)：Codex CLI 和内置 Vim 模式。
