#!/usr/bin/env bash

# 1. Détection robuste du dossier du script (pour Bash)
# BASH_SOURCE[0] est la seule variable fiable quand on utilise 'source'
CURRENT_SCRIPT_PATH="${BASH_SOURCE[0]}"
REAL_DIR=$(dirname "$(readlink -f "$CURRENT_SCRIPT_PATH")")

# 2. Sécurité : on définit le répertoire cible
MY_GIT_DIR="${MY_GIT_DIR:-$HOME/Mes-Donnees/Git}"

REPOS=("home-manager" "info_doc" "install-script" "nixos-dotfiles" "scripts" "user-dotfiles")

echo "--- 📥 Gestion des dépôts Git (Mode Source) ---"

for repo in "${REPOS[@]}"; do
    TARGET="$MY_GIT_DIR/$repo"
    
    if [ -d "$TARGET" ]; then
        echo "🔄 $repo : Mise à jour..."
        # Utilisation de -C pour être indépendant du dossier actuel
        git -C "$TARGET" pull
    else
        echo "🚀 $repo : Clonage..."
        git clone "https://github.com/binnotkari-wq/$repo.git" "$TARGET"
    fi
done
