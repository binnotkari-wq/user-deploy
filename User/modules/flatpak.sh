#!/usr/bin/env bash

echo "--- 📦 Installation des applications Flatpak ---"

# 1. Ajout du dépôt Flathub (indispensable)
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
mkdir -p ~/.flatpak-tmp # création du répertoire des fichiers temporaires de flatpak, dans le dossier utilisateur (la variable d'environnement est dans .bashrc géré par Stow)

# 2. Liste d'applications COMMUNES (partout)
APPS_COMMUNES=(
    "com.heroicgameslauncher.hgl"
)com.ranfdev.DistroShelf

# 3. Liste d'applications par Environnement de Bureau (D.E.)
APPS_GNOME=(
    "org.gnome.gitlab.somas.Apostrophe"
    "org.gnome.Boxes"
    "com.ranfdev.DistroShelf"
    "org.gimp.GIMP"
    "org.libreoffice.LibreOffice"
    "org.gnome.gitlab.YaLTeR.VideoTrimmer"
    "io.github.revisto.drum-machine"
    "io.gitlab.adhami3310.Impression"
    "garden.jamie.Morphosis"
    "org.scratchmark.Scratchmark"
    "fr.handbrake.ghb"
    "com.github.jeromerobert.pdfarranger"
    "tv.kodi.Kodi"
    "org.gnome.DejaDup"
    "de.haeckerfelix.Fragments"
    "com.github.johnfactotum.Foliate"
    "io.github.celluloid_player.Celluloid"
    "com.github.PintaProject.Pinta"
    "org.gnome.World.Secrets"
    "net.nokyan.Resources"
    "de.haeckerfelix.Shortwave"
)

APPS_GNOME_FEDORA_ATOMIC=(

    "org.gnome.Music"
    "org.gnome.Calculator"
    "org.gnome.NautilusPreviewer"
    "org.gnome.Characters"
    "org.gnome.TextEditor "
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
) 

APPS_KDE=(
    # "org.kde.okular"
    # "org.kde.gwenview"
    # "org.kde.kcalc"
)

# 4. Logique d'installation

echo "🚀 Installation des applications communes..."
flatpak install --user -y flathub "${APPS_COMMUNES[@]}"

# Détection du D.E. actuel
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
    echo "🎨 Environnement GNOME détecté, installation des apps dédiées..."
    flatpak install --user -y flathub "${APPS_GNOME[@]}"
    if grep -qE "silverblue|kinoite|bazzite" /etc/os-release 2>/dev/null; then
        flatpak install --user -y flathub "${APPS_GNOME_FEDORA_ATOMIC[@]}"
    fi
elif [[ "$XDG_CURRENT_DESKTOP" == *"KDE"* ]]; then
    echo "💎 Environnement KDE détecté, installation des apps dédiées..."
    flatpak install --user -y flathub "${APPS_KDE[@]}"
else
    echo "ℹ️  Environnement inconnu ($XDG_CURRENT_DESKTOP), installation des apps D.E. ignorée."
fi

echo "Nettoyage des résidus éventuels"
flatpak uninstall --unused
echo "✅ Flatpaks installés avec succès."
