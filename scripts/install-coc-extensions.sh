#!/usr/bin/env bash
set -euo pipefail

names=(coc-clangd coc-css coc-json coc-lua coc-go coc-pyright)
packages=("${names[@]}")
coc_ext_dir="${XDG_CONFIG_HOME:-$HOME/.config}/coc/extensions"

if ! command -v npm >/dev/null 2>&1; then
  echo "npm not found; install Node.js/npm first" >&2
  exit 1
fi

node_major="$(node -p 'process.versions.node.split(".")[0]')"
if ((node_major < 22)); then
  # coc-css 2.2+ requires Node 22; 2.1.0 is the last Node 20-compatible release.
  packages[1]="coc-css@2.1.0"
fi

mkdir -p "$coc_ext_dir"
if [[ ! -f "$coc_ext_dir/package.json" ]]; then
  printf '{"dependencies":{}}\n' > "$coc_ext_dir/package.json"
fi

echo "Installing coc extensions via npm: ${packages[*]}"
cd "$coc_ext_dir"

if command -v timeout >/dev/null 2>&1; then
  timeout 300 npm install --no-audit --no-fund --no-progress "${packages[@]}"
else
  npm install --no-audit --no-fund --no-progress "${packages[@]}"
fi

missing=()
for name in "${names[@]}"; do
  if [[ ! -d "$coc_ext_dir/node_modules/$name" ]]; then
    missing+=("$name")
  fi
done

if ((${#missing[@]})); then
  echo "coc extensions missing after install: ${missing[*]}" >&2
  exit 1
fi

echo "coc extensions installed: ${names[*]}"
