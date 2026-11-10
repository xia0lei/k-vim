#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
source_file="$repo_dir/coc-settings.json"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/coc"
target="$config_dir/coc-settings.json"

if [[ ! -f "$source_file" ]]; then
  echo "coc-settings.json not found: $source_file" >&2
  exit 1
fi

mkdir -p "$config_dir"

if [[ -L "$target" ]]; then
  current="$(readlink "$target")"
  if [[ "$current" == "$source_file" ]]; then
    echo "already linked: $target -> $source_file"
    exit 0
  fi
fi

if [[ -e "$target" || -L "$target" ]]; then
  backup="$target.bak.$(date +%Y%m%d%H%M%S)"
  mv "$target" "$backup"
  echo "backed up existing settings: $target -> $backup"
fi

ln -s "$source_file" "$target"
echo "linked: $target -> $source_file"
