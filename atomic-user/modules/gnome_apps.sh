{ config, pkgs, ... }:

{
  # The home.packages option allows you to install Nix packages into your environment.
  home.packages = with pkgs; [
    kiwix-tools               # moteur wikipedia local. Lancer avec kiwix-serve --port 8080 "/chemin/vers/fichier.zim"
    llama-cpp-vulkan          # moteur LLM, interface web type Gemini / Chat GPT. Ne prend que 80 Mo : install de base.
    fragments                 # Équivalent de KTorrent (Client BitTorrent GTK)
    foliate                   # lecteur ebook
    celluloid                 # lecteur de vidéos
    pinta                     # logiciel de dessin
    gnome-secrets             # gestionnaire de mots # en flatpak c'est très biende passe compatible keepass
    resources
    shortwave
    zenity                    # pour affichier des boites de dialoguedans des scripts
  ]; 
}
