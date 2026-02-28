# Installation de Distrobox. Préférer avec brew.

# Distrobox
if ! command -v distrobox &> /dev/null; then
    echo "  -> Installation de distrobox..."
    # le script officiel installe correctement l'ensemble des fichiers dans .local
    curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local
fi
