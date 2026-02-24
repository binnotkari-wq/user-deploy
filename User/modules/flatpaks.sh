#!/usr/bin/env bash

echo "--- 📦 Installation des applications Flatpak ---"

# 1. Ajout du dépôt Flathub (indispensable)
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
mkdir -p ~/.flatpak-tmp # création du répertoire des fichiers temporaires de flatpak, dans le dossier utilisateur (la variable d'environnement est dans .bashrc géré par Stow)

# 2. Liste d'applications COMMUNES (partout)
APPS_COMMUNES=(
    "com.heroicgameslauncher.hgl"
)

# 3. Liste d'applications par Environnement de Bureau (D.E.)
APPS_GNOME=(
    "org.gnome.Music"
    "org.gnome.DejaDup"
    "org.gnome.Boxes"
    "org.gnome.World.Secrets"
    "org.gnome.gitlab.YaLTeR.VideoTrimmer"
    "org.gnome.gitlab.somas.Apostrophe"
    "com.github.jeromerobert.pdfarranger"
    "com.github.johnfactotum.Foliate"
    "com.github.PintaProject.Pinta"
    "io.github.revisto.drum-machine"
    "io.github.celluloid_player.Celluloid"
    "io.gitlab.adhami3310.Impression"
    "net.nokyan.Resources"sudo sensors-detect
    "de.haeckerfelix.Shortwave"
    "de.haeckerfelix.Fragments"
    "com.ranfdev.DistroShelf"
    "org.gimp.GIMP"
    "org.libreoffice.LibreOffice"
    "garden.jamie.Morphosis"
    "org.scratchmark.Scratchmark"
    "fr.handbrake.ghb"
    "tv.kodi.Kodi"
)

# 4. Logique d'installation

flatpak install --user -y flathub "${APPS_COMMUNES[@]}"
flatpak install --user -y flathub "${APPS_GNOME[@]}"
echo "Nettoyage des résidus éventuels"
flatpak uninstall --unused
echo "✅ Flatpaks installés avec succès."
