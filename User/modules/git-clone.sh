#!/usr/bin/env bash


REPOS=("home-manager" "install-script" "nixos-dotfiles" "scripts" "info_doc" "user-dotfiles")

mkdir -p $GIT_DIR
cd $GIT_DIR
echo "--- Début de l'importation des repos depuis Github ---"
for repo in "${REPOS[@]}"; do
    git clone https://github.com/binnotkari-wq/$repo.git
done
