#!/usr/bin/env bash

echo "--- 📦 Installation des applications Flatpak (system-wide) ---"

# 1. Ajout du dépôt Flathub (indispensable)
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 2. Liste d'applications par Environnement de Bureau (D.E.)
APPS_GNOME_SYSTEM=(
    "org.gnome.Calculator"
    "org.gnome.NautilusPreviewer"
    "org.gnome.Characters"
    "org.gnome.TextEditor"
    "org.gnome.Weather"
    "org.gnome.Loupe"
    "org.gnome.Extensions"
    "org.gnome.Snapshot"
    "org.gnome.baobab"
    "org.gnome.Maps"
    "org.gnome.font-viewer"
    "org.gnome.clocks"
    "org.gnome.Papers"
    "org.gnome.Logs"
    "org.gnome.Decibels"
    "org.gnome.SimpleScan"
    "io.github.ilya_zlobintsev.LACT"
) 

# 3. Installation
flatpak install --system -y flathub "${APPS_GNOME_SYSTEM[@]}"
echo "Nettoyage des résidus éventuels"
flatpak uninstall --unused
echo "✅ Flatpaks installés avec succès (system-wide)."
