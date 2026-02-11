#!/usr/bin/env bash
set -e

# --- INSTALLATION ET DEPLOIEMENT DE HOME MANAGER ---

echo "📡 Configuration des canaux Nix (Branche Stable 25.11)..."
nix-channel --add https://nixos.org/channels/nixos-25.11 nixpkgs
nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz home-manager
nix-channel --update

echo "📡 Initialisation Home Manager
export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
nix-shell '<home-manager>' -A install
home-manager switch -f /home/benoit/Mes-Donnees/Git/home-manager/home.nix

echo "🎉 Home Manager installé"
