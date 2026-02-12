#!/usr/bin/env bash

echo "--- 📦 Installation des applications Flatpak ---"

# 1. Ajout du dépôt Flathub (indispensable)
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
mkdir -p ~/.flatpak-tmp # création du répertoire des fichiers temporaires de flatpak, dans le dossier utilisateur (la variable d'environnement est dans .bashrc géré par Stow)

# 2. Liste d'applications COMMUNES (partout)
APPS_COMMUNES=(
    # "org.mozilla.firefox"
    # "org.videolan.VLC"
    # "com.visualstudio.code"
    # "org.telegram.desktop"
    # "com.bitwarden.desktop"
    "com.heroicgameslauncher.hgl"
)

# 3. Liste d'applications par Environnement de Bureau (D.E.)
APPS_GNOME=(
    # "org.gnome.Geary"
    # "org.gnome.Extensions"
    # "org.gnome.Lollypop"
    "org.gnome.gitlab.somas.Apostrophe"
)

APPS_KDE=(
    # "org.kde.okular"
    # "org.kde.gwenview"
    # "org.kde.kcalc"
)

# --- Logique d'installation ---

echo "🚀 Installation des applications communes..."
flatpak install --user -y flathub "${APPS_COMMUNES[@]}"

# Détection du D.E. actuel
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
    echo "🎨 Environnement GNOME détecté, installation des apps dédiées..."
    flatpak install --user -y flathub "${APPS_GNOME[@]}"
elif [[ "$XDG_CURRENT_DESKTOP" == *"KDE"* ]]; then
    echo "💎 Environnement KDE détecté, installation des apps dédiées..."
    flatpak install --user -y flathub "${APPS_KDE[@]}"
else
    echo "ℹ️  Environnement inconnu ($XDG_CURRENT_DESKTOP), installation des apps D.E. ignorée."
fi

echo "✅ Flatpaks installés avec succès."
