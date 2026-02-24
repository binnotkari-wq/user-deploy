#!/usr/bin/env bash

# Ce script est utilisé par Fedora Atomic.

echo "🛡️ Préparation et réglages système : Fedora Atomic (Silverblue / Bazzite / Kinoite)"

# 1. Nettoyage des flatpaks Fedora (system-wide)
sudo flatpak pin --remove $(flatpak list --system --columns=ref | grep "fedoraproject") 2>/dev/null || true
sudo flatpak uninstall -y $(flatpak list --columns=application,origin | grep -i 'fedora' | awk '{print $1}') 2>/dev/null || true
sudo flatpak uninstall --unused
sudo flatpak remote-delete --force fedora 2>/dev/null || true
sudo flatpak uninstall --unused


# 2. Optimisation btrfs (discard=async et bien prévu de base et traverse LUKS, noatime est déjà là aussi)
# Ajoute compress=zstd aux lignes btrfs qui n'ont pas encore d'option de compression
# On ajoute l'option après 'relatime' (standard sur Fedora Silverblue)
echo "Vérification de la compression ZSTD dans /etc/fstab..."
sudo sed -i '/btrfs/ { /compress=zstd/! s/relatime/&,compress=zstd/ }' /etc/fstab
# Le !  : C'est le "NOT". Il dit à sed : "Si tu vois déjà compress=zstd, ne touche à rien, passe à la suite".

# On lance la compression en arrière-plan pour l'existant
# Note : on utilise /sysroot car c'est là que pointe la racine physique sur Silverblue
# echo "Lancement de la compression initiale (peut prendre un moment)..."
# sudo btrfs filesystem defragment -r -v -czstd /sysroot &
# sudo btrfs filesystem defragment -r -v -czstd /var &
# sudo btrfs filesystem defragment -r -v -czstd /var/home &




echo "✨ Fin du module Atomic."
