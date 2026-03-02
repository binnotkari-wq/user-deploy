#!/usr/bin/env bash

# --- Configuration ---
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# 1. Applications standards (dans ~/.config)
APPS=("bash" "btop" "htop" "foot" "zellij" "kate" "mc" "pyradio" "PBE" "applications" "celluloid" "fragments" "kiwix-desktop" "shortcuts")

# 2. Applications Flatpak (dans ~/.var/app)
FLATPAKS=(
    "org.gnome.Calculator" "org.gnome.NautilusPreviewer" "org.gnome.TextEditor"
    "org.gnome.Weather" "org.gnome.Loupe" "org.gnome.Extensions"
    "org.gnome.baobab" "org.gnome.Maps" "org.gnome.clocks"
    "org.gnome.Papers" "org.gnome.Decibels" "org.gnome.SimpleScan"
    "org.gnome.Music" "org.gnome.gitlab.YaLTeR.VideoTrimmer"
    "org.gnome.gitlab.somas.Apostrophe" "com.github.jeromerobert.pdfarranger"
    "com.github.johnfactotum.Foliate" "com.github.PintaProject.Pinta"
    "io.github.revisto.drum-machine" "io.github.celluloid_player.Celluloid"
    "io.gitlab.adhami3310.Impression" "net.nokyan.Resources"
    "de.haeckerfelix.Shortwave" "de.haeckerfelix.Fragments"
    "org.gimp.GIMP" "org.libreoffice.LibreOffice"
    "garden.jamie.Morphosis" "org.scratchmark.Scratchmark"
    "fr.handbrake.ghb" "tv.kodi.Kodi" "org.gnome.meld"
)

# Fichier de sauvegarde Gnome
GNOME_CONF="$DOTFILES_DIR/gnome/settings.dconf"
mkdir -p "$DOTFILES_DIR/gnome"

echo "=================================================="
echo "   Gestionnaire de Dotfiles (Stow + Flatpaks)"
echo "=================================================="
echo "1) [MIGRER]    Local -> Depot (Sauvegarde)"
echo "2) [DÉPLOYER]  Depot -> Local (Installation)"
echo "3) [QUITTER]"
read -p "Votre choix [1-3] : " CHOICE

case $CHOICE in
    1)
        echo "--- 📸 Capture des réglages Gnome (Dconf) ---"
        echo "--- 📸 Capture sélective des réglages Gnome ---"
	{
	  dconf dump /org/gnome/desktop/
	  dconf dump /org/gnome/shell/
 	  dconf dump /org/gnome/settings-daemon/plugins/media-keys/
	} > "$GNOME_CONF"
        echo "[OK] Gnome sauvegardé."


        echo "--- 📦 Migration Apps Standards (~/.config) ---"
        for APP in "${APPS[@]}"; do
            if [ -d "$HOME/.config/$APP" ] && [ ! -L "$HOME/.config/$APP" ]; then
                echo "Migration de $APP..."
                mkdir -p "$DOTFILES_DIR/$APP/.config"
                mv "$HOME/.config/$APP" "$DOTFILES_DIR/$APP/.config/"
                stow -v -t "$HOME" "$APP"
            else
                echo "✅ $APP déjà géré ou absent."
            fi
        done

        echo "--- 📦 Migration Flatpaks (~/.var/app) ---"
        for FP in "${FLATPAKS[@]}"; do
            FP_PATH="$HOME/.var/app/$FP"
            if [ -d "$FP_PATH" ] && [ ! -L "$FP_PATH" ]; then
                echo "Migration du Flatpak : $FP..."
                mkdir -p "$DOTFILES_DIR/flatpaks/.var/app"
                mv "$FP_PATH" "$DOTFILES_DIR/flatpaks/.var/app/"
                # On ne lance stow qu'une fois à la fin pour le dossier global 'flatpaks'
            else
                echo "✅ Flatpak $FP déjà géré ou absent."
            fi
        done
        # Application du lien symbolique global pour les flatpaks
        stow -v -t "$HOME" flatpaks
        ;;

    2)   
# 1. Sécurité pour les fichiers existants (Bash, etc.)
        # On peut généraliser : si un fichier existe en vrai dans $HOME, on le déplace
        for APP in "${APPS[@]}"; do
            if [ -f "$HOME/.$APP" ] && [ ! -L "$HOME/.$APP" ]; then
                echo "⚠️ Sauvegarde de .$APP existant en .$APP.bak"
                mv "$HOME/.$APP" "$HOME/.$APP.bak"
            fi
        done

        echo "--- 🔗 Liaison des fichiers (Stow) ---"
        cd "$DOTFILES_DIR"

        # Apps classiques
        for APP in "${APPS[@]}"; do
            if [ -d "$APP" ]; then
                stow -R -v -t "$HOME" "$APP"
            else
                echo "⏭️ Saut de $APP (dossier absent)"
            fi
        done

        # Flatpaks (on applique le même traitement de faveur)
        if [ -d "flatpaks" ]; then
            echo "--- 📦 Liaison des configurations Flatpaks ---"
            stow -R -v -t "$HOME" flatpaks
        fi

        echo "--- 🎨 Application des réglages Gnome ---"
        if [ -f "$GNOME_CONF" ]; then
            # On utilise / pour être sûr de tout restaurer, 
            # ou /org/gnome/ pour être sélectif.
            dconf load / < "$GNOME_CONF"
            echo "[OK] Gnome mis à jour."
        else
            echo "ℹ️ Aucun fichier dconf trouvé."
        fi
        ;;

    *)
        echo "Au revoir !"
        exit 0
        ;;
esac

echo "=========================================="
echo "Opération terminée avec succès."
