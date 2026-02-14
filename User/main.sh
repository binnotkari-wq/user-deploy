#!/usr/bin/env bash

# --- DEPLOIEMENT DE L'ENVIRONNEMENT UTILISATEUR ---
set -e # Arrête le script en cas d'erreur

# On définit le répertoire Git (évite d'exporter si non nécessaire par la suite)
MY_GIT_DIR="$HOME/Mes-Donnees/Git"
export MY_GIT_DIR # (utilisé par git-clone.sh et home-manager.sh)


echo "--- [1/4] Mise en place des repos Git ---"
source ./modules/git-clone.sh 

echo "--- [2/4] Configuration de l'OS ---"

# CAS 1 : SYSTÈME AVEC NIX (NixOS ou autre avec /nix manuel)
if [ -d "/nix" ]; then
    echo "❄️  Nix détecté : Activation de Home Manager..."
    source ./modules/home-manager.sh
fi

# CAS 2 : SYSTÈME ATOMIC (Fedora Silverblue, Bazzite, Kinoite)
if grep -qE "silverblue|kinoite|bazzite" /etc/os-release 2>/dev/null; then
    echo "🛡️  Système Atomic détecté : Configuration des outils binaires et Toolbx..."
    source ./modules/atomic.sh
fi

echo "--- [3/4] Installation des Flatpaks ---"
source ./modules/flatpak.sh

echo "--- [4/4] Import des préférences utilisateur (Stow) ---"
source ./modules/stow.sh

echo "✅ Déploiement terminé ! Redémarre ton terminal."
