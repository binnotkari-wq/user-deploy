#!/usr/bin/env bash

# Installation des outils CLI

echo "--- 📦 Installation des applications et outils CLI ---"

# Téléchargement et installation de Brew. Brew permet d'installer des logiciels CLI en espace utilisateur.
# Brew sera installé dans /home/linuxbrew/.linuxbrew/. Le script s'occupe de régler les permissions.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# On indique au shell où trouver brew
echo >> $HOME/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >> "$HOME/.bashrc"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
source ~/.bashrc # on recharge la configuration de l'environnement shell

# Installation des logiciels et outils en CLI
# powertop et compsize ne sont pas disponibles dans Brew

# Liste
APPS_CLI=(
    "gcc"
    "mc"
    "lm-sensors"
    "zellij"
    "btop"
    "htop"
    "stow"
    "duf"
    "mdcat"
    "stress-ng"
    "just"
    "go"
    "dialog"
)

# Installation
brew install "${APPS_CLI[@]}"
echo "--- 📦 Applications et outils CLI installés ---"
