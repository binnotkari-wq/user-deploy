#!/usr/bin/env bash

echo "🛡️ Réglages système et installation des outils CLI : Fedora Atomic (Silverblue / Bazzite / Kinoite)"

# 1. Gestion des binaires indisponibles dans toolbx
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
echo "📥 Installation des binaires dans $BIN_DIR..."
echo "   Ils seront automatiquement reconnus grâce à ton .bashrc (via Stow)."

# Kiwix
if ! command -v kiwix-manage &> /dev/null; then
    echo "  -> Récupération de Kiwix Tools..."
    # On télécharge, on décompresse et on ne garde que le binaire
    curl -L "https://download.kiwix.org/release/kiwix-tools/kiwix-tools_linux-x86_64.tar.gz" | tar -xz -C "$BIN_DIR" --strip-components=1
fi

# Zellij
if ! command -v zellij &> /dev/null; then
    echo "  -> Installation de Zellij..."
    curl -L "https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz" | tar -xz -C "$BIN_DIR"
fi

# Mdcat
if ! command -v mdcat &> /dev/null; then
    echo "  -> Installation de Mdcat..."
    curl -L "https://github.com/swsnr/mdcat/releases/download/mdcat-2.7.1/mdcat-2.7.1-x86_64-unknown-linux-gnu.tar.gz" | tar -xz -C "$BIN_DIR"
fi

# llama.cpp vulkan
LLAMA_DIR="$HOME/.local/lib/llama-cpp"
mkdir -p "$LLAMA_DIR"
if ! command -v llama-server &> /dev/null; then
    echo "  -> Installation de llama.cpp Vulkan..."
    # On crée le wrapper dans ~/.local/bin
    cat <<EOF > "$BIN_DIR/llama"
#!/usr/bin/env bash
export LD_LIBRARY_PATH="$LLAMA_DIR:\$LD_LIBRARY_PATH"
exec "$LLAMA_DIR/llama-cli" "\$@"
EOF
    chmod +x "$HOME/.local/bin/llama"
    curl -L "https://github.com/ggml-org/llama.cpp/releases/download/b8012/llama-b8012-bin-ubuntu-vulkan-x64.tar.gz" | tar -xz -C "$LLAMA_DIR"  --strip-components=1
fi


# 2. Création de la Toolbx
TBX_NAME="CLI_tools"

if ! toolbox list | grep -q "$TBX_NAME"; then
    echo "🏗️  Création de la Toolbx : $TBX_NAME..."
    toolbox create -c "$TBX_NAME" -y
    echo "📦 Pré-installation des utilitaires essentiels dans la Toolbx..."
    # On installe le strict minimum pour que tu puisses travailler dedans immédiatement
    toolbox run -c "$TBX_NAME" sudo dnf install -y bash-completion duf compsize powertop stow stress-ng python313 s-tui htop btop mc
else
    echo "✅ Toolbx '$TBX_NAME' déjà opérationnelle."
fi


# 3. Préconfiguration de Git
setup_git_credentials() {
    echo "🔑 Configuration de l'authentification Git..."

    # 1. On définit l'identité (nécessaire pour Git)
    git config --global user.name "binnotkari-wq"
    git config --global user.email "benoit.dorczynski@gmail.com"

    # 2. On configure le gestionnaire de certificats
    git config --global credential.helper store

    # 3. Pré-remplissage optionnel (La méthode "silencieuse")
    # Si tu as ton token GitHub sous la main (via une variable d'env ou un fichier secret)
    # on peut créer le fichier de credentials manuellement.
    if [ -n "$GITHUB_TOKEN" ]; then
        echo "https://binnotkari-wq:$GITHUB_TOKEN@github.com" > ~/.git-credentials
        chmod 600 ~/.git-credentials
        echo "✅ Token GitHub pré-enregistré."
    else
        echo "ℹ️  Le prochain push/pull demandera ton token et le mémorisera."
    fi
}


# 4. Service de synchro automatique de Git à la fermeture de session
setup_sync_service() {
    echo "⚙️  Configuration du service de synchronisation Git au shutdown..."
    SERVICE_DIR="$HOME/.config/systemd/user"
    SERVICE_FILE="$SERVICE_DIR/git-sync-on-shutdown.service"
    mkdir -p "$SERVICE_DIR"

    cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Synchronisation Git des dépôts à la fermeture de session
After=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/true
ExecStop=$HOME/Mes-Donnees/Git/scripts/git-sync.sh

[Install]
WantedBy=default.target
EOF

    # Recharger systemd et activer le service
    systemctl --user daemon-reload
    systemctl --user enable git-sync-on-shutdown.service
    systemctl --user start git-sync-on-shutdown.service

    # Réglage : lorsque ce service s'exécute, attendre la fin de l'execution avant d'éteindre le pc
    sudo loginctl enable-linger $USER
    echo "✅ Service installé et activé."
}



# 5. Optimisation btrfs (discard=async et bien prévu de base et traverse LUKS, noatime est déjà là aussi)

# Ajoute compress=zstd aux lignes btrfs qui n'ont pas encore d'option de compression
# On ajoute l'option après 'relatime' (standard sur Fedora Silverblue)
echo "Vérification de la compression ZSTD dans /etc/fstab..."
sudo sed -i '/btrfs/ { /compress=zstd/! s/relatime/&,compress=zstd/ }' /etc/fstab
# Le !  : C'est le "NOT". Il dit à sed : "Si tu vois déjà compress=zstd, ne touche à rien, passe à la suite".

# Avant de traiter les données existantes du SSD avec la compression zstd, on supprime le remote flatpak fedora puisqu'à terme on ne le garde pas
sudo flatpak pin --remove $(flatpak list --system --columns=ref | grep "fedoraproject") 2>/dev/null || true
sudo flatpak uninstall --system --all -y
sudo flatpak uninstall --unused
sudo flatpak remote-delete --force fedora 2>/dev/null || true
sudo flatpak uninstall --unused

# On lance la compression en arrière-plan pour l'existant
# Note : on utilise /sysroot car c'est là que pointe la racine physique sur Silverblue
echo "Lancement de la compression initiale (peut prendre un moment)..."
sudo btrfs filesystem defragment -r -v -czstd /sysroot &
sudo btrfs filesystem defragment -r -v -czstd /var &
sudo btrfs filesystem defragment -r -v -czstd /var/home &

echo "-------------------------------------------------------"
echo "BILAN DE LA COMPRESSION (via compsize dans la toolbox)"
echo "-------------------------------------------------------"

# On appelle compsize à l'intérieur de la toolbox 'fedora-toolbox-43'
# On analyse /run/host qui est le miroir du système réel
toolbox run -c fedora-toolbox-43 sudo compsize -x /run/host/var/home /run/host/var /run/host/sysroot


echo "✨ Fin du module Atomic."
