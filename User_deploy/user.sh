#!/usr/bin/env bash

# --- DEPLOIEMENT DE L'ENVIRONNEMENT UTILISATEUR ---
set -e # Arrête le script en cas d'erreur

echo "--- [1/3] Mise en place de Git ---"
./modules/git.sh

echo "--- [2/3] Import des préférences utilisateur (Stow) ---"
./modules/stow.sh

echo "--- [3/3] Installation des Flatpaks ---"
./modules/flatpaks.sh

echo "✅ Déploiement terminé ! Redémarre le pc!"
