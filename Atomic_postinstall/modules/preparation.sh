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
sudo rm -rf /var/lib/flatpak/.removed/*

# 2. Optimisation btrfs (discard=async est bien prévu de base, noatime est déjà là aussi)
echo "✨ Application et vérification de la compression ZSTD dans /etc/fstab..."

# Sauvegarde du fstab et vérification avant de continuer
sudo cp /etc/fstab /etc/fstab.bak
if [ ! -f /etc/fstab.bak ]; then
    echo "❌ Erreur : Impossible de créer la sauvegarde /etc/fstab.bak. Arrêt du script."
    exit 1
fi

# Détection du CPU pour le niveau de compression
THREADS=$(nproc)
if [ "$THREADS" -le 4 ]; then
    LEVEL=1
else
    LEVEL=3
fi

# Ajout de l'option de base si absente, en se basant sur la colonne 'btrfs'
sudo sed -i '/btrfs/ { /compress=zstd/! s/\(btrfs\s\+\)\(\S\+\)/\1\2,compress=zstd/ }' /etc/fstab

# Harmonisation du niveau de compression (zstd:1 ou zstd:3)
sudo sed -i "s/compress=zstd\(:[0-9]\+\)\?/compress=zstd:$LEVEL/g" /etc/fstab

echo "✅ Configuration Btrfs réglée sur zstd:$LEVEL (CPU $THREADS threads)."


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
