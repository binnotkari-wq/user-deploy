#!/usr/bin/env bash

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

echo "🛡️ Installation des outils CLI (compatible toute distrib sauf Nixos qui gère les outils CLI en nixpkgs)"

# Téléchargement et installation de Brew. Brew permet d'installer des logiciels CLI en espace utilisateur.
# Brew sera installé dans /home/linuxbrew/.linuxbrew/. Le script s'occupe de régler les permissions.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# On indique au shell où trouver brew
echo >> $HOME/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >> "$HOME/.bashrc"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
source ~/.bashrc # on recharge la configuration de l'environnement shell

# Installation des logiciels et outils en CLI
# powertop et compsize ne sont pas disponibles dans Brew

# Liste
APPS_CLI=(
    "gcc"
    "mc"
    "lm-sensors"
    "zellij"
    "btop"
    "htop"
    "stow"
    "duf"
    "mdcat"
    "stress-ng"
    "just"
    "go"
    "dialog"
)

# Installation
brew install "${APPS_CLI[@]}"
echo "--- 📦 Applications et outils CLI installés ---"




# 2. Mise en place des binaires standalone qui ne sont pas disponibles en Toolbox

echo "📥 Installation des binaires dans $BIN_DIR..."

# Kiwix
if ! command -v kiwix-manage &> /dev/null; then
    echo "  -> Récupération de Kiwix Tools..."
    curl -L "https://download.kiwix.org/release/kiwix-tools/kiwix-tools_linux-x86_64.tar.gz" | tar -xz -C "$BIN_DIR" --strip-components=1
fi

# Zellij (Version MUSL - Excellente pour la portabilité)
if ! command -v zellij &> /dev/null; then
    echo "  -> Installation de Zellij..."
    # Zellij est souvent un binaire seul dans le .tar.gz, pas de strip-components ici
    curl -L "https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz" | tar -xz -C "$BIN_DIR"
    chmod +x "$BIN_DIR/zellij"
fi

# Mdcat
if ! command -v mdcat &> /dev/null; then
    echo "  -> Installation de Mdcat..."
    # On utilise un dossier temporaire pour ne prendre QUE le binaire et pas les docs/licences
    TEMP_DIR=$(mktemp -d)
    curl -L "https://github.com/swsnr/mdcat/releases/download/mdcat-2.7.1/mdcat-2.7.1-x86_64-unknown-linux-gnu.tar.gz" | tar -xz -C "$TEMP_DIR"
    mv "$TEMP_DIR"/mdcat-*/mdcat "$BIN_DIR/"
    rm -rf "$TEMP_DIR"
    chmod +x "$BIN_DIR/mdcat"
fi

# Distrobox
if ! command -v distrobox &> /dev/null; then
    echo "  -> Installation de distrobox..."
    # le script officiel installe correctement l'ensemble des fichiers dans .local
    curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local
fi

# llama.cpp vulkan
LLAMA_DIR="$HOME/.local/lib/llama-cpp"
mkdir -p "$LLAMA_DIR"
if ! command -v llama &> /dev/null; then
    echo "  -> Installation de llama.cpp Vulkan..."
    # Téléchargement et extraction propre
    curl -L "https://github.com/ggml-org/llama.cpp/releases/download/b8012/llama-b8012-bin-ubuntu-vulkan-x64.tar.gz" | tar -xz -C "$LLAMA_DIR" --strip-components=1
    
    # Création du wrapper dans ~/.local/bin
    cat <<EOF > "$BIN_DIR/llama"
#!/usr/bin/env bash
export LD_LIBRARY_PATH="$LLAMA_DIR:\$LD_LIBRARY_PATH"
exec "$LLAMA_DIR/llama-cli" "\$@"
EOF
    chmod +x "$BIN_DIR/llama"
fi

echo "✅ Installation terminée pour Silverblue."
