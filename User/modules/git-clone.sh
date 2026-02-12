#!/usr/bin/env bash

# Sécurité : valeur par défaut si GIT_DIR n'est pas défini
GIT_DIR="${GIT_DIR:-$HOME/Mes-Donnees/Git}"

REPOS=("home-manager" "info_doc" "install-script" "nixos-dotfiles" "scripts" "user-dotfiles")

# Création du répertoire parent
mkdir -p "$GIT_DIR"
cd "$GIT_DIR"

echo "--- 📥 Gestion des dépôts Git ---"

for repo in "${REPOS[@]}"; do
    if [ -d "$repo" ]; then
        echo "🔄 $repo existe déjà, mise à jour (pull)..."
        # On va dans le dossier, on pull, et on revient
        (cd "$repo" && git pull)
    else
        echo "🚀 Clonage de $repo..."
        git clone "https://github.com/binnotkari-wq/$repo.git"
    fi
done

echo "--- ✅ Tous les dépôts sont prêts ---"
