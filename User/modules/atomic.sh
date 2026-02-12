#!/usr/bin/env bash

# --- MODULE FEDORA ATOMIC (Silverblue / Bazzite / Kinoite) ---

echo "🛡️  Installation des outils CLI"

# 1. Création des répertoires de base
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"
LLAMA_DIR="$HOME/.local/lib/llama-cpp"
mkdir -p "$LLAMA_DIR"


# 2. Gestion des binaires indisponibles dans toolbx
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


# 3. Création de la Toolbx

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

echo "✨ Fin du module Atomic."


