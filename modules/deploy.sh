#!/usr/bin/env bash

# modules/deploy.sh

echo -e "\n--- [PHASE DE DÉPLOIEMENT : $SCENARIO] ---"

# --- 1. CONFIGURATION DES CHEMINS ---
DOTFILES_SOURCE="../nixos-dotfiles"
# Chemin final pour que tes .nix soient accessibles une fois booté
DOTFILES_TARGET="/mnt/home/$TARGET_USER/Mes-Donnees/Git/nixos-dotfiles"

# --- 2. LOGISTIQUE DES FICHIERS ---
if [[ "$SCENARIO" != "REPARATION" ]]; then
    echo "💾 Création du swapfile (4Go)..."
    btrfs filesystem mkswapfile --size 4g /mnt/swap/swapfile
    swapon /mnt/swap/swapfile

    echo "🔑 Configuration du mot de passe utilisateur..."
    mkdir -p /mnt/persist/etc/secrets
    # mkpasswd demandera le mot de passe et créera le hash
    mkpasswd -m yescrypt | tee /mnt/persist/etc/secrets/${TARGET_USER}-password > /dev/null
    chmod 600 /mnt/persist/etc/secrets/${TARGET_USER}-password

    echo "📂 Préparation du dossier cible..."
    mkdir -p "$(dirname "$DOTFILES_TARGET")"
    
    echo "📂 Copie des dotfiles vers le @home préservé..."
    cp -r "$DOTFILES_SOURCE" "$DOTFILES_TARGET"

    echo "⚙️  Génération de la configuration matérielle (UUIDs)..."
    sleep 2
    nixos-generate-config --root /mnt
    
    # On déplace le fichier généré vers l'endroit attendu par tes dotfiles
    HW_TARGET_DIR="$DOTFILES_TARGET/hardware-support/hardware-configuration"
    mkdir -p "$HW_TARGET_DIR"
    cp "/mnt/etc/nixos/hardware-configuration.nix" "$HW_TARGET_DIR/${TARGET_HOSTNAME}_hardware-configuration.nix"
    echo "✅ Fichier hardware copié dans $HW_TARGET_DIR"
    
    # On donne la propriété à l'utilisateur cible (1000 est l'ID standard du premier user)
    echo "👤 Ajustement des propriétaires (chown)..."
    chown -R 1000:1000 "/mnt/home/$TARGET_USER"
    chown -R 1000:100 "$DOTFILES_TARGET"
fi

# --- 3. LOGIQUE D'INSTALLATION / RÉPARATION ---

if [[ "$SCENARIO" == "REPARATION" ]]; then
    echo -e "\n🛠️  MODE RÉPARATION"
    echo "Corrigez vos fichiers dans : $DOTFILES_TARGET"
    read -p "Prêt pour le rebuild ? (tapez 'yes') : " REPAIR_CONFIRM
    if [[ "$REPAIR_CONFIRM" == "yes" ]]; then
        nixos-enter --root /mnt -c "nixos-rebuild boot -I nixos-config=$DOTFILES_TARGET/$TARGET_HOSTNAME.nix"
    fi
else
    echo -e "\n⚠️  DERNIER AVERTISSEMENT AVANT INSTALLATION"
    echo "Machine : $TARGET_HOSTNAME | Utilisateur : $TARGET_USER"
    read -p "Lancer l'installation NixOS ? (tapez 'yes') : " FINAL_CONFIRM
    
    if [[ "$FINAL_CONFIRM" == "yes" ]]; then
        echo "🚀 Installation en cours..."
        # On utilise -I pour bien pointer vers le dossier de dotfiles qu'on vient de remplir
        nixos-install --root /mnt --no-root-passwd -I "nixos-config=$DOTFILES_TARGET/$TARGET_HOSTNAME.nix"
    else
        echo "Installation annulée."
    fi
fi
