#!/usr/bin/env bash

# 0. Détection de l'utilisateur et du HOME (robuste pour NixOS/Silverblue)
USER_NAME=$(whoami)
USER_HOME=$HOME
MY_GIT_DIR="$USER_HOME/Mes-Donnees/Git"

echo "🛡️ Mise en place de Git pour $USER_NAME"
mkdir -p $MY_GIT_DIR

# 1. Préconfiguration de Git
setup_git_credentials() {
    echo "🔑 Configuration de l'authentification Git..."
    git config --global user.name "binnotkari-wq"
    git config --global user.email "benoit.dorczynski@gmail.com"
    git config --global credential.helper store
    
    # Sécurité pour éviter les erreurs de "dossier non sûr" sur NixOS
    git config --global --add safe.directory "$USER_HOME/Mes-Donnees/Git/*"

    if [ -n "$GITHUB_TOKEN" ]; then
        echo "https://binnotkari-wq:$GITHUB_TOKEN@github.com" > "$USER_HOME/.git-credentials"
        chmod 600 "$USER_HOME/.git-credentials"
        echo "✅ Token GitHub pré-enregistré."
    fi
}

# 2. Service de synchro automatique
setup_sync_service() {
    echo "⚙️ Configuration du service systemd..."
    SERVICE_DIR="$USER_HOME/.config/systemd/user"
    SERVICE_FILE="$SERVICE_DIR/git-sync-on-shutdown.service"
    mkdir -p "$SERVICE_DIR"

    # On trouve le chemin de 'true' de façon dynamique pour NixOS/Silverblue
    TRUE_PATH=$(command -v true)

    cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Synchronisation Git des dépôts à la fermeture de session
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=$TRUE_PATH
# On injecte le chemin complet calculé pour éviter les problèmes de variables
ExecStop=$USER_HOME/Mes-Donnees/Git/scripts/git-sync.sh

[Install]
WantedBy=default.target
EOF

    systemctl --user daemon-reload
    systemctl --user enable git-sync-on-shutdown.service
    
    # Linger est crucial pour que les services --user tournent au shutdown sur Silverblue
    loginctl enable-linger "$USER_NAME"
    echo "✅ Service systemd configuré."
}

# 3. Téléchargements des repos 

# Détection robuste du dossier du script (pour Bash)
CURRENT_SCRIPT_PATH="${BASH_SOURCE[0]}"
REAL_DIR=$(dirname "$(readlink -f "$CURRENT_SCRIPT_PATH")")

REPOS=("archives" "home-manager" "info_doc" "user-deploy" "nixos-dotfiles" "nixos-install_script" "atomic-install_script" "scripts" "user-dotfiles")

echo "--- 📥 Gestion des dépôts Git (Mode Source) ---"

for repo in "${REPOS[@]}"; do
    TARGET="$MY_GIT_DIR/$repo"
    
    if [ -d "$TARGET" ]; then
        echo "🔄 $repo : Mise à jour..."
        # Utilisation de -C pour être indépendant du dossier actuel
        git -C "$TARGET" pull
    else
        echo "🚀 $repo : Clonage..."
        git clone "https://github.com/binnotkari-wq/$repo.git" "$TARGET"
    fi
done

# Lancer les fonctions
setup_git_credentials
setup_sync_service

echo "✨ Git en place et synchronisation configurée."
