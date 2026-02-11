#!/usr/bin/env bash

# --- Configuration ---
DOTFILES_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
APPS=("btop" "htop" "foot" "zellij" "kate" "mc" "pyradio" "PBE" "applications" "celluloid" "dconf" "fragments" "kiwix-desktop")

# Fichier de sauvegarde Gnome dans ton repo
GNOME_CONF="$DOTFILES_DIR/gnome/settings.dconf"
mkdir -p "$DOTFILES_DIR/gnome"

echo "=========================================="
echo "   Importation de Dotfiles (Stow + Gnome)"
echo "=========================================="

        echo "--- 🔗 Liaison des fichiers (Stow) ---"
        for APP in "${APPS[@]}"; do
            if [ -d "$APP" ]; then
                stow -v -t "$HOME" "$APP"
            fi
        done

        echo "--- 🎨 Application des réglages Gnome ---"
        if [ -f "$GNOME_CONF" ]; then
            dconf load /org/gnome/ < "$GNOME_CONF"
            echo "[OK] Gnome mis à jour."
        fi
        ;;

    *)
        echo "Au revoir !"
        exit 0
        ;;
esac

echo "=========================================="
echo "Opération terminée avec succès."
