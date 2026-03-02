#!/usr/bin/env bash

# Script à utiliser pour Fedora Atomic (Silverblue / Kinoite / Ublue )".
# Ce script est à lancer une première fois pour la préparation et réglages système préliminaires qui provoqueront un reboot.
# Suite au reboot, on relance ce script. L'étape de préparation et réglages système préliminaires sera automatiquement sautée pour passer
# aux étapes suivantes.

# --- ENRICHISSEMENT DU SYSTEME - AUCUNE MODIFICATION OSTREE ---


set -e # Arrête le script en cas d'erreur
chmod +x ./modules/*.sh

# Cette partie ne s'exécute que si elle n'a jamais été exécutée. Si on détecte qu'il existe un des résultats de l'exécution de cette partie, on passe directement à la suite. Sinon, on exécute cette partie
if grep -q "compress=zstd" /etc/fstab; then
    echo "--- [1/3] (Préparation et réglages système préliminaires) déjà exécutée lors de la session précédente. On continue... ---"
else
    echo "--- [1/3] Préparation et réglages système préliminaires ---"
    ./modules/preparation.sh # ce module provoquera le reboot du PC à la fin de son exécution.
    echo "-------------------------------------------------------"
fi


echo "--- [2/3] Compression des fichiers existants (toute nouvelle donnée sera quand à elle compressée automatiquement) ---"
./modules/compression.sh

echo "--- [3/3] Installation des outils en ligne de commande ---"
./modules/CLI_tools.sh

echo "✅ Déploiement terminé ! Redémarre le pc!"
