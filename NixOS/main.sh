#!/usr/bin/env bash

# main.sh - Chef d'orchestre de l'installation NixOS (Dell 5485)

# --- 1. Accueil et Choix du Scénario ---
clear
echo "======================================================="
echo "   GESTIONNAIRE D'INSTALLATION NIXOS - SCÉNARIOS"
echo "======================================================="
echo ""
echo "Choisissez votre scénario d'intervention :"
echo "1) [WIPE TOTAL]    : Efface tout (Partitions, LUKS, Données)"
echo "2) [REINSTALL]     : Garde @home, recrée @nix, @swap, @persist et /boot"
echo "3) [REPARATION]    : Monte le système existant pour maintenance"
echo ""

read -p "Entrez votre choix (1, 2 ou 3) : " CHOIX

case $CHOIX in
    1) SCENARIO="WIPE_TOTAL" ;;
    2) SCENARIO="REINSTALL" ;;
    3) SCENARIO="REPARATION" ;;
    *) echo "Choix invalide. Sortie."; exit 1 ;;
esac

# --- 2. Point d'étape : Validation Manuelle ---
echo ""
echo "-------------------------------------------------------"
echo -e "ATTENTION : Vous avez choisi le mode : **$SCENARIO**"
echo "-------------------------------------------------------"
if [ "$SCENARIO" == "WIPE_TOTAL" ]; then
    echo "DANGER : Le SSD sera entièrement vidé. Toutes les données seront perdues."
elif [ "$SCENARIO" == "REINSTALL" ]; then
    echo "NOTE : Votre partition /home sera préservée, le reste sera réinitialisé."
fi
echo ""

read -p "Confirmez-vous cette procédure ? (tapez 'yes' pour continuer) : " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Opération annulée."
    exit 0
fi

# --- 3. Lancement des sous-modules ---
# On utilise le chemin relatif vers ton dossier 'modules'
export SCENARIO

echo "--- [1/3] Chargement des variables ---"
source ./modules/variables.sh

echo "--- [2/3] Préparation du disque ---"
source ./modules/disk-setup.sh

echo "--- [3/3] Déploiement du système ---"
source ./modules/deploy.sh

echo "Félicitations, l'intervention $SCENARIO est terminée."
