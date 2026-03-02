#!/usr/bin/env bash

# Script à utiliser pour Fedora Atomic (Silverblue / Kinoite / Ublue )"

echo " Installation des outils CLI (compatible toute distrib sauf Nixos qui gère les outils CLI en nixpkgs)"



# -----------------------------------------------------------
# -----------------------------------------------------------
# -----------------------------------------------------------
# 1. Mise en place des binaires Brew
echo "🛡️ ...binaires Brew..."

# Téléchargement et installation de Brew. Brew permet d'installer des logiciels CLI en espace utilisateur.
# Brew sera installé dans /home/linuxbrew/.linuxbrew/. Le script s'occupe de régler les permissions.
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Gestion des PATH pour Homebrew
# On s'assure que le dossier de configuration locale existe
mkdir -p "$HOME/.bashrc.d"

# On crée (ou écrase) le fichier dédié à Brew sans toucher au .bashrc de Stow
cat << 'EOF' > "$HOME/.bashrc.d/homebrew.bash"
# Configuration Homebrew (Spécifique Fedora Atomic)
if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    # Initialisation de l'environnement Brew
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
    
    # Sécurité : on place Brew en fin de PATH pour ne pas écraser l'OS
    export PATH="$PATH:/home/linuxbrew/.linuxbrew/bin"
    
    # On garantit que les binaires système restent prioritaires
    export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
fi
EOF

# Application immédiate pour la session actuelle
source "$HOME/.bashrc.d/homebrew.bash"
echo "Configuration Brew isolée dans ~/.bashrc.d/homebrew.bash"

# Installation des logiciels et outils en CLI
# (ne pas installer distrobox via brew, car cela va installer également une version brew de podman, alors que celui-ci est
# installé nativement sur les Fedora Atomic (Silverblue, Bazzite ...). Distrobox sera donc installé en binaire natif standalone
# (voir plus bas). Powertop n'est pas disponibles dans Brew
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
echo "--- 📦 Applications et outils installés via Brew ---"
# -----------------------------------------------------------
# -----------------------------------------------------------
# -----------------------------------------------------------




# -----------------------------------------------------------
# -----------------------------------------------------------
# -----------------------------------------------------------
# 2. Mise en place des binaires standalone qui ne sont pas disponibles dans brew
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
echo "📥 ...binaires standalone (dans $BIN_DIR)..."

# Kiwix
if ! command -v kiwix-manage &> /dev/null; then
    echo "  -> Récupération de Kiwix Tools..."
    curl -L "https://download.kiwix.org/release/kiwix-tools/kiwix-tools_linux-x86_64.tar.gz" | tar -xz -C "$BIN_DIR" --strip-components=1
fi

# llama.cpp vulkan
LLAMA_DIR="$HOME/.local/lib/llama-cpp"
mkdir -p "$LLAMA_DIR"
if ! command -v llama-server &> /dev/null; then
    echo "  -> Installation de llama.cpp Vulkan..."
    # Téléchargement et extraction propre
    curl -L "https://github.com/ggml-org/llama.cpp/releases/download/b8012/llama-b8012-bin-ubuntu-vulkan-x64.tar.gz" | tar -xz -C "$LLAMA_DIR" --strip-components=1

    # Création du wrapper dans ~/.local/bin
    cat <<EOF > "$BIN_DIR/llama-server"
#!/usr/bin/env bash
export LD_LIBRARY_PATH="$LLAMA_DIR:\$LD_LIBRARY_PATH"
exec "$LLAMA_DIR/llama-server" "\$@"
EOF
    chmod +x "$BIN_DIR/llama-server"
fi


# Distrobox
if ! command -v distrobox &> /dev/null; then
    echo "  -> Installation de distrobox..."
    # le script officiel installe correctement l'ensemble des fichiers dans .local
    curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local
fi
# -----------------------------------------------------------
# -----------------------------------------------------------
# -----------------------------------------------------------

echo "--- 📦 Applications et outils installés dans $BIN_DIR ---"
echo "✅ Installation terminée pour Silverblue."
