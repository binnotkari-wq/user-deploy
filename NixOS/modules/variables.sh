#!/usr/bin/env bash

# modules/variables.sh
# Ce script est sourcé par main.sh et définit l'environnement de travail.

echo -e "\n--- [COLLECTE DES PARAMÈTRES] ---"

# --- 1. SÉLECTION DU DISQUE (CIBLE) ---
echo -e "\nDisques physiques détectés :"
lsblk -dn -o NAME,SIZE,MODEL | grep -v "loop"
echo ""

while true; do
    read -p "Entrez le nom du disque (ex: nvme0n1) : " DISK_NAME
    if [ -b "/dev/$DISK_NAME" ]; then
        export DISK="/dev/$DISK_NAME"
        echo -e "   OK: Disque $DISK sélectionné."
        break
    else
        echo -e "   ERREUR: /dev/$DISK_NAME n'existe pas. Réessayez."
    fi
done

# --- 2. SÉLECTION DU HOSTNAME (MACHINE) ---
# On remonte de deux cran pour aller dans nixos-dotfiles/
DOTFILES_DIR="../../nixos-dotfiles"

echo -e "\nConfigurations machines détectées dans $DOTFILES_DIR :"
# On liste les fichiers .nix à la racine des dotfiles
ls -1 "$DOTFILES_DIR"/*.nix | xargs -n 1 basename | sed 's/\.nix//'
echo ""

read -p "Entrez le nom de la machine (ex: dell-5485) : " TARGET_HOSTNAME
export TARGET_HOSTNAME

# --- 3. SÉLECTION DE L'UTILISATEUR ---
USER_CONFIG_DIR="../nixos-dotfiles/software-setup/users"

echo -e "\nProfils utilisateurs détectés :"
# On liste en ignorant les fichiers "-settings.nix"
ls -1 "$USER_CONFIG_DIR"/*.nix | grep -v "-settings.nix" | xargs -n 1 basename | sed 's/\.nix//'
echo ""

# On propose "benoit" par défaut
read -p "Entrez l'utilisateur principal [par défaut: benoit] : " USER_INPUT
export TARGET_USER=${USER_INPUT:-"benoit"}

echo -e "\n--- [RÉCAPITULATIF DES VARIABLES] ---"
echo "DISK            : $DISK"
echo "HOSTNAME        : $TARGET_HOSTNAME"
echo "USER            : $TARGET_USER"
echo "--------------------------------------"
