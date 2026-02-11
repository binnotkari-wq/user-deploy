#!/usr/bin/env bash

# --- DEPLOIEMENT DE L'ENVIRONNEMENT UTILISATEUR ---

set -e
GIT_DIR="$HOME/Mes-Donnees/Git"
export GIT_DIR

# Variables d'environnement
echo 'export HISTTIMEFORMAT = "%d/%m/%y %T "' >> ~/.bashrc
echo 'export EDITOR = "nano"' >> ~/.bashrc

# c'est la bonne syntaxe ?
export PROMPT_COMMAND='history -a'
echo "# SESSION $(date +%s) $$" >> ~/.bash_history


### c'est la bonne syntaxe ?
      if [[ $SHLVL -eq 1 ]]; then
        history -s "# SESSION $(date +%s) $$"
        history -a
      fi




echo "--- [1/4] Mise en place des repos Git ---"
source ./modules/git-clone.sh

# --- SEULEMENT SI OS AVEC NIX ---
echo "--- [2/4] Installation de Home Manager ---"
if [ -d "/nix" ]; then
  source ./modules/home-manager.sh
fi

echo "--- [3/4] Installation des Flatpaks ---"
source ./modules/flatpak.sh

echo "--- [4/4] Import des préférence utilisateur ---"
source ./modules/stow.sh
