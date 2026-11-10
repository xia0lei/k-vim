" Local Vim overrides (generic).
" Loaded after vimrc/bundles via ~/.vim/after/plugin/; keep k-vim core untouched.

" ---------------------------------------------------------------------------
" Colors: enable true color and provide :Theme [name]
" ---------------------------------------------------------------------------
function! s:AirlineTheme(name) abort
  if !empty(globpath(&runtimepath, 'autoload/airline/themes/' . a:name . '.vim'))
    let g:airline_theme = a:name
    silent! AirlineRefresh
  endif
endfunction

if has('termguicolors')
  set termguicolors
  if exists('g:colors_name') && !empty(g:colors_name)
    execute 'colorscheme ' . g:colors_name
    call s:AirlineTheme(g:colors_name)
  endif
endif

let s:theme_names = [
      \ 'molokai', 'gruvbox', 'dracula', 'nord', 'onedark', 'everforest',
      \ 'catppuccin_mocha', 'catppuccin_latte', 'catppuccin_frappe',
      \ 'catppuccin_macchiato', 'solarized',
      \ ]

function! s:CompleteColors(ArgLead, CmdLine, CursorPos) abort
  return getcompletion(a:ArgLead, 'color')
endfunction

function! s:Theme(name) abort
  if a:name !~# '^[A-Za-z0-9_-]\+$'
    echohl ErrorMsg | echo '主题名无效' | echohl None
    return
  endif
  execute 'colorscheme ' . a:name
  call s:AirlineTheme(a:name)
endfunction

function! s:ThemePick() abort
  let l:available = filter(copy(s:theme_names),
        \ '!empty(globpath(&runtimepath, "colors/" . v:val . ".vim"))')
  if empty(l:available)
    echohl WarningMsg | echo '没有可用主题' | echohl None
    return
  endif
  let l:items = map(copy(l:available), 'v:key + 1 . ". " . v:val')
  let l:choice = inputlist(['选择主题（0 取消）:'] + l:items)
  if l:choice > 0 && l:choice <= len(l:available)
    call s:Theme(l:available[l:choice - 1])
  endif
endfunction

function! s:ThemeCommand(name) abort
  if empty(a:name)
    call s:ThemePick()
  else
    call s:Theme(a:name)
  endif
endfunction

command! -nargs=? -complete=customlist,<SID>CompleteColors Theme
      \ call s:ThemeCommand(<q-args>)
nnoremap <silent> <leader>tc :Theme<CR>

" Reload this overlay without restarting Vim.
command! ReloadLocal source ~/.vim/after/plugin/local.vim
nnoremap <silent> <leader>sl :ReloadLocal<CR>

" ---------------------------------------------------------------------------
" Search: ripgrep for :grep, CtrlP and quickfix
" ---------------------------------------------------------------------------
if executable('rg')
  let &grepprg = 'rg --vimgrep --smart-case --hidden -g "!.git/*"'
  let &grepformat = '%f:%l:%c:%m'
  let g:ctrlp_user_command = 'rg --files %s --hidden --glob "!.git/*"'
  let g:ctrlp_use_caching = 0
endif

" Keep CtrlP file search and MRU scoped to the current project root.
let g:ctrlp_working_path_mode = 'r'
let g:ctrlp_mruf_relative = 1
" Refresh CtrlP's cached MRU options when this overlay is re-sourced.
if exists('*ctrlp#mrufiles#opts')
  silent! call ctrlp#mrufiles#opts()
endif

" ---------------------------------------------------------------------------
" Lint: coc handles Lua/Go LSP; ALE keeps Python/JS/shell linters.
" Lua/Go ALE is disabled to avoid duplicate diagnostics with coc-lua/coc-go.
" ---------------------------------------------------------------------------
let g:ale_linters = {
      \ 'python': ['flake8'],
      \ 'javascript': ['eslint'],
      \ 'sh': ['shellcheck'],
      \ 'lua': [],
      \ 'go': [],
      \ }

" vim-go defaults to goimports; fall back to gofmt when it is not installed.
if !executable('goimports')
  let g:go_fmt_command = 'gofmt'
endif

" Tagbar needs ctags. Keep F9 usable but show a clear message when missing.
if !executable('ctags')
  nnoremap <silent> <F9> :echo 'Tagbar 需要 ctags：安装 universal-ctags 后重试'<CR>
endif

" ---------------------------------------------------------------------------
" Project and Lua helpers
" ---------------------------------------------------------------------------
function! s:ProjectRoot() abort
  let l:root = systemlist('git -C ' . shellescape(expand('%:p:h')) . ' rev-parse --show-toplevel 2>/dev/null')
  return (v:shell_error == 0 && !empty(l:root)) ? l:root[0] : getcwd()
endfunction

function! s:CtrlPMRUProject() abort
  let l:root = s:ProjectRoot()
  if !empty(l:root)
    execute 'lcd ' . fnameescape(l:root)
  endif
  CtrlPMRU
endfunction

nnoremap <silent> <leader>f :call <SID>CtrlPMRUProject()<CR>

function! s:LuaCompiler(root) abort
  if exists('b:lua_check_compiler') && !empty(b:lua_check_compiler)
    return b:lua_check_compiler
  endif
  if exists('g:lua_check_compiler') && !empty(g:lua_check_compiler)
    return g:lua_check_compiler
  endif
  " Prefer a project-bundled Skynet luac when present; otherwise PATH luac.
  let l:bundled = a:root . '/skynet/3rd/lua/luac'
  return executable(l:bundled) ? l:bundled : 'luac'
endfunction

function! s:LuaCheck() abort
  let l:luac = s:LuaCompiler(s:ProjectRoot())
  if !executable(l:luac)
    echohl WarningMsg | echo '未找到 luac，无法检查 Lua 语法' | echohl None
    return
  endif
  let l:output = system(shellescape(l:luac) . ' -p ' . shellescape(expand('%:p')))
  if v:shell_error == 0
    echohl MoreMsg | echo 'Lua 语法检查通过' | echohl None
    return
  endif
  echohl ErrorMsg | echo substitute(l:output, '\n\+$', '', '') | echohl None
endfunction

augroup local_lua
  autocmd!
  autocmd FileType lua nnoremap <buffer> <silent> <leader>lc :LuaCheck<CR>
  autocmd FileType lua command! -buffer LuaCheck call <SID>LuaCheck()
augroup END

" Coc diagnostic navigation.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Project-wide ripgrep; type the pattern after the command.
nnoremap <silent> <leader>gg :grep!<space>

" ---------------------------------------------------------------------------
" AI CLIs: Claude Code / Codex terminal splits
" ---------------------------------------------------------------------------
function! s:Agent(kind, command) abort
  for l:info in getbufinfo()
    if getbufvar(l:info.bufnr, 'local_agent_kind', '') ==# a:kind
      let l:winnr = bufwinnr(l:info.bufnr)
      if l:winnr != -1
        execute l:winnr . 'wincmd w'
        return
      endif
    endif
  endfor
  execute 'botright vertical split'
  execute 'lcd ' . fnameescape(s:ProjectRoot())
  execute 'terminal ++curwin ' . a:command
  let b:local_agent_kind = a:kind
  setlocal nonumber norelativenumber nolist
  tnoremap <buffer> <C-q> <C-\><C-n>
  nnoremap <buffer> <C-q> :q<CR>
endfunction

command! -nargs=0 ClaudeTerm call s:Agent('claude', 'claude')
command! -nargs=0 ClaudeContinue call s:Agent('claude-continue', 'claude --continue')
command! -nargs=0 ClaudeResume call s:Agent('claude-resume', 'claude --resume')
command! -nargs=0 CodexTerm call s:Agent('codex', 'codex')
command! -nargs=0 CodexResume call s:Agent('codex-resume', 'codex resume --last')
nnoremap <silent> <leader>ac :ClaudeTerm<CR>
nnoremap <silent> <leader>aC :ClaudeContinue<CR>
nnoremap <silent> <leader>aR :ClaudeResume<CR>
nnoremap <silent> <leader>ax :CodexTerm<CR>
nnoremap <silent> <leader>aX :CodexResume<CR>

" Reload files changed by an external agent when returning to Vim.
augroup local_autoread
  autocmd!
  autocmd FocusGained,BufEnter * checktime
augroup END

" ---------------------------------------------------------------------------
" Filetype defaults that differ from k-vim
" ---------------------------------------------------------------------------
augroup local_filetypes
  autocmd!
  autocmd FileType markdown setlocal wrap linebreak nolist
  autocmd FileType sh setlocal tabstop=4 shiftwidth=4 softtabstop=4 expandtab
augroup END
