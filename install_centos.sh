#!/bin/bash
# Install system dependencies for k-vim on CentOS 9 Stream

echo "Installing system packages..."
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y epel-release
sudo dnf install -y \
    git \
    curl \
    cmake \
    python3-devel \
    python3-pip \
    ctags \
    the_silver_searcher \
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
