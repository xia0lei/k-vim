#!/bin/bash
# Install system dependencies for k-vim on macOS (Homebrew)

if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Please install it first: https://brew.sh/"
    exit 1
fi

echo "Installing system packages..."
brew update
brew install \
    git \
    cmake \
    python3 \
    universal-ctags \
    the_silver_searcher \
    node \
    llvm \
    golang

# Link llvm to get clangd if not in path
echo 'export PATH="/usr/local/opt/llvm/bin:$PATH"' >> ~/.zshrc

echo "Installing language specific tools..."
# Python tools
pip3 install flake8 yapf isort

# Javascript & Lua tools
npm install -g eslint luacheck

echo "System dependencies installation done!"
echo "Now you can run ./install.sh to setup vim configurations."
