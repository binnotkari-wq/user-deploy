#!/usr/bin/env bash

echo " Installation des outils CLI (compatible toute distrib sauf Nixos qui gère les outils CLI en nixpkgs)"

# 1. Mise en place des binaires Brew
echo "🛡️ ...binaires Brew..."

# Téléchargement et installation de Brew. Brew permet d'installer des logiciels CLI en espace utilisateur.
# Brew sera installé dans /home/linuxbrew/.linuxbrew/. Le script s'occupe de régler les permissions.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# On indique au shell où trouver brew
echo >> $HOME/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"' >> "$HOME/.bashrc"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
source ~/.bashrc # on recharge la configuration de l'environnement shell

# Installation des logiciels et outils en CLI
# powertop n'est pas disponibles dans Brew

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
    "distrobox"
    "podman"
)

# Installation
brew install "${APPS_CLI[@]}"
echo "--- 📦 Applications et outils installés via Brew ---"


# 2. Mise en place des binaires standalone qui ne sont pas disponibles dans brew
echo "📥 ...binaires standalone (dans $BIN_DIR)..."

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

# Kiwix
if ! command -v kiwix-manage &> /dev/null; then
    echo "  -> Récupération de Kiwix Tools..."
    curl -L "https://download.kiwix.org/release/kiwix-tools/kiwix-tools_linux-x86_64.tar.gz" | tar -xz -C "$BIN_DIR" --strip-components=1
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

echo "--- 📦 Applications et outils installés dans $BIN_DIR ---"
echo "✅ Installation terminée pour Silverblue."
