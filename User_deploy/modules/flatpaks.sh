#!/usr/bin/env bash

# Nota bene : on banni le mode --user pour les flatpaks. Pour une question de sécurité : installation "systeme" pour que personne (ni un utilisateur, ni un logiciel malveillant) ne puisse altérer les outils de base. En installation mode --user, un logiciel malveillant n'a besoin d'aucun privilège particulier pour alterer le contenu d'un flatpak. De plus, l'installation en mode --user n'isole pas plus les flatpaks. En mode système, il sont dans /var/lib, et donc deja en dehors des fichiers de l'OS (aucune pollution).

echo "--- 📦 Installation des applications Flatpak (system-wide) ---"

# 1. Ajout du dépôt Flathub (indispensable)
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 2. Liste d'applications par Environnement de Bureau (D.E.)
APPS_COMMUNES=(
    "com.heroicgameslauncher.hgl"
)

APPS_GNOME=(
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
    "org.gnome.Music"
    "org.gnome.DejaDup"
    "org.gnome.Boxes"
    "org.gnome.World.Secrets"
    "org.gnome.gitlab.YaLTeR.VideoTrimmer"
    "org.gnome.gitlab.somas.Apostrophe"
    "org.mozilla.firefox"
    "io.github.ilya_zlobintsev.LACT"
    "com.github.jeromerobert.pdfarranger"
    "com.github.johnfactotum.Foliate"
    "com.github.PintaProject.Pinta"
    "io.github.revisto.drum-machine"
    "io.github.celluloid_player.Celluloid"
    "io.gitlab.adhami3310.Impression"
    "net.nokyan.Resources"
    "ca.desrt.dconf-editor"
    "de.haeckerfelix.Shortwave"
    "de.haeckerfelix.Fragments"
    "com.ranfdev.DistroShelf"
    "org.gimp.GIMP"
    "org.libreoffice.LibreOffice"
    "garden.jamie.Morphosis"
    "org.scratchmark.Scratchmark"
    "fr.handbrake.ghb"
    "tv.kodi.Kodi"
    "org.gnome.meld"
)

# 3. Installation
flatpak install --system -y flathub "${APPS_COMMUNES[@]}"
flatpak install --system -y flathub "${APPS_GNOME[@]}"
echo "Nettoyage des résidus éventuels"
flatpak uninstall --unused

# 4. Préférences spécifiques au flatpaks
flatpak run --command=gsettings org.gnome.TextEditor set org.gnome.TextEditor draw-spaces "['space', 'tab', 'newline', 'trailing']"

echo "✅ Flatpaks installés avec succès (system-wide)."
