#!/usr/bin/env bash

# Script à utiliser pour Fedora Atomic (Silverblue / Kinoite / Ublue )"

echo "Compression des fichiers existants (peut prendre un moment)..."
sudo btrfs filesystem defragment -r -v -czstd /var &
sudo btrfs filesystem defragment -r -v -czstd /var/home &
echo "Compression des fichiers existants terminée."
