#!/usr/bin/env bash

# Script à utiliser pour Fedora Atomic (Silverblue / Kinoite / Ublue )"
# Purge des Flatpaks installés par défaut, puis ajout des optimisations BTRFS (système de fichier par défaut des distributions basées sur Fedora Atomic)

echo "🛡️ Préparation et réglages système : Fedora Atomic (Silverblue / Kinoite / Ublue )"

# 1. Nettoyage des flatpaks Fedora (system-wide)
sudo flatpak pin --remove $(flatpak list --system --columns=ref | grep "fedoraproject") 2>/dev/null || true
sudo flatpak uninstall -y $(flatpak list --columns=application,origin | grep -i 'fedora' | awk '{print $1}') 2>/dev/null || true
sudo flatpak uninstall --unused
sudo flatpak remote-delete --force fedora 2>/dev/null || true
sudo flatpak uninstall --unused


# 2. Optimisation btrfs (discard=async et bien prévu de base et traverse LUKS, noatime est déjà là aussi)
# Ajoute compress=zstd aux lignes btrfs qui n'ont pas encore d'option de compression
# On ajoute l'option après 'relatime' (standard sur Fedora Silverblue)
echo "✨ Application et vérification de la compression ZSTD dans /etc/fstab..."
sudo sed -i '/btrfs/ { /compress=zstd/! s/relatime/&,compress=zstd/ }' /etc/fstab
# Le !  : C'est le "NOT". Il dit à sed : "Si tu vois déjà compress=zstd, ne touche à rien, passe à la suite".


# 3. Redémarrage obligatoire
while true; do
    echo "-------------------------------------------------------"
    echo " ETAPE TERMINEE : LE REDÉMARRAGE EST REQUIS."
    echo "-------------------------------------------------------"
    read -p "Tapez 'REBOOT' pour confirmer que vous êtes prêt : " input

    # On vérifie si l'entrée est exactement "REBOOT" (en majuscules)
    if [[ "$input" == "REBOOT" ]]; then
        echo "Initialisation du redémarrage..."
        sudo systemctl reboot
        break # Au cas où le reboot met du temps à se lancer
    else
        echo -e "\n[ERREUR] Action annulée. Vous devez redémarrer pour appliquer les changements.\c"
        sleep 1
        clear # Optionnel : nettoie l'écran pour garder le message bien visible
    fi
done
