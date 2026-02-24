#!/usr/bin/env bash

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

echo "🛡️ Installation des outils CLI (Spécifique Silverblue)"

# 1. Création de la Toolbx pour les outils qui y sont disponibles

# Nommer la Toolbox
TBX_NAME="CLI_tools"


# Lister les applications CLI
APPS_TOOLBOX=(
    lm_sensors
    dialog      # outils pratique pour créer des boites de dialogue dans les scripts
    duf         # analyse  espace disque
    powertop    # gestion d'énèrgie https://commandmasters.com/commands/powertop-linux/
    stow        # Gestionnaire de dotfiles (gestion automatisée de liens symboliques vers ~/.config/  -> permet de faire un repo github rationnel) 
    stress-ng   # outil de stress CPU : stress-ng --cpu 0 --cpu-method matrixprod -v
    python313   # prend 45 Mo. Préférer à la version 315 qui prend 130 Mo
    s-tui       # Interface graphique CLI pour monitorer fréquence/température. Prend 49 Mo, dont la majorité en commun avec python 313
    htop        # gestionnaire de processus
    btop        # gestionnaire de processus, plus graphique
    mc          # gestionnaire de fichiers. Prend 45 Mo, mais la majeur parti est commune aux dépendances de python313
    just
)

# Mise en place de la Toolbox
if ! toolbox list | grep -q "$TBX_NAME"; then
    echo "🏗️  Création de la Toolbx : $TBX_NAME..."
    toolbox create -c "$TBX_NAME" -y
    echo "📦 Pré-installation des utilitaires essentiels dans la Toolbx..."
    toolbox run -c "$TBX_NAME" sudo dnf install -y "${APPS_TOOLBOX[@]}"
else
    echo "✅ Toolbx '$TBX_NAME' déjà opérationnelle."
fi


# Création des wrapper dans .local/bin
echo "🛠️ Création des wrappers Toolbox dans $BIN_DIR..."

for app in "${APPS_TOOLBOX[@]}"; do
    WRAPPER_PATH="$BIN_DIR/$app"
    
    # On crée le mini-script wrapper
    cat <<EOF > "$WRAPPER_PATH"
#!/usr/bin/env bash
exec toolbox run -c "$TBX_NAME" "/usr/bin/$app" "\$@"
EOF

    # On le rend exécutable
    chmod +x "$WRAPPER_PATH"
    echo "  ✅ Wrapper créé pour : $app"
done

echo "🚀 Terminé ! Tu peux maintenant taper '${APPS_TOOLBOX[0]}' directement dans ton terminal hôte."

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
