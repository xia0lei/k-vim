#!/bin/bash
# Install system dependencies for k-vim on Ubuntu

echo "Installing system packages..."
sudo apt-get update
sudo apt-get install -y \
    git \
    curl \
    cmake \
    build-essential \
    python3-dev \
    python3-pip \
    universal-ctags \
    silversearcher-ag \
    nodejs \
    npm \
    clangd \
    golang

echo "Installing language specific tools..."
# Python tools
sudo pip3 install flake8 yapf isort

# Javascript & Lua tools
sudo npm install -g eslint luacheck

echo "System dependencies installation done!"
echo "Now you can run ./install.sh to setup vim configurations."
