#!/usr/bin/env bash

mkdir -p ~/.flatpak-tmp
echo 'export FLATPAK_DOWNLOAD_TMPDIR="$HOME/.flatpak-tmp"' >> ~/.bashrc
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install --user flathub LA_LISTE_DES_APPS
