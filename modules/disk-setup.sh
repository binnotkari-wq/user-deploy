#!/usr/bin/env bash

# modules/disk-setup.sh

echo -e "\n--- [PRÉPARATION DU DISQUE : $SCENARIO] ---"

# --- 1. DÉFINITION DES PARTITIONS ---
if [[ $DISK == *"nvme"* || $DISK == *"mmcblk"* ]]; then
    PART_BOOT="${DISK}p1"
    PART_LUKS="${DISK}p2"
else
    PART_BOOT="${DISK}1"
    PART_LUKS="${DISK}2"
fi

PART_BTRFS="/dev/mapper/cryptroot"

# --- 2. NETTOYAGE (Uniquement si WIPE_TOTAL) ---
if [[ "$SCENARIO" == "WIPE_TOTAL" ]]; then
    echo "🏗️  Wipe total : suppression de la table de partition..."
    sgdisk --zap-all "$DISK"
    echo "🏗️  Création des partitions GPT..."
    sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"BOOT" "$DISK"
    sgdisk -n 2:0:0      -t 2:8300 -c 2:"SYSTEM" "$DISK"
    
    echo "🔐 Chiffrement LUKS2..."
    # On utilise la variable LUKS_PASS si on veut automatiser, sinon cryptsetup demande
    cryptsetup luksFormat --type luks2 "$PART_LUKS"
fi


# --- 3. OUVERTURE ET FORMATAGE ---
# L'ouverture est systématique (sauf si déjà ouvert, d'où le || true)
echo "🔓 Ouverture du conteneur chiffré..."
cryptsetup open "$PART_LUKS" cryptroot || echo "Déjà ouvert."

if [[ "$SCENARIO" == "WIPE_TOTAL" ]]; then
    echo "🧹 Formatage Btrfs (Neuf)..."
    mkfs.btrfs -f -L NIXOS "$PART_BTRFS"
    echo "🧹 Formatage Boot (VFAT)..."
    mkfs.vfat -F 32 -n BOOT "$PART_BOOT"
elif [[ "$SCENARIO" == "REINSTALL" ]]; then
    echo "🧹 Formatage Boot (VFAT) pour réinstallation propre..."
    mkfs.vfat -F 32 -n BOOT "$PART_BOOT"
fi

# --- 4. GESTION DES SOUS-VOLUMES BTRFS ---
# On ne touche aux sous-volumes que si on n'est pas en mode REPARATION
if [[ "$SCENARIO" != "REPARATION" ]]; then
    echo "📦 Gestion des sous-volumes Btrfs..."
    mount "$PART_BTRFS" /mnt
    
    # En mode REINSTALL, on supprime ce qui n'est pas précieux
    if [[ "$SCENARIO" == "REINSTALL" ]]; then
        for sub in @nix @persist @swap; do
            btrfs subvolume delete "/mnt/$sub" 2>/dev/null || true
        done
    fi

    # On crée ce qui manque (WIPE créera tout, REINSTALL créera les 3 supprimés, @home reste)
    [[ ! -d "/mnt/@nix" ]]     && btrfs subvolume create "/mnt/@nix"
    [[ ! -d "/mnt/@persist" ]] && btrfs subvolume create "/mnt/@persist"
    [[ ! -d "/mnt/@home" ]]    && btrfs subvolume create "/mnt/@home"
    [[ ! -d "/mnt/@swap" ]]    && btrfs subvolume create "/mnt/@swap"
    
    umount /mnt
fi

# --- 5. MONTAGES FINAUX (Commun à tous les modes) ---

sudo udevadm trigger --subsystem-match=block # On force udev à rafraîchir les UUID immédiatement
sleep 2 # on laisse le temps aux infos de partions d'être mises à jour
sudo partprobe $DISK # Rafraichi la détection de la nouvelle table de partitions
sleep 2 # on laisse le temps aux infos de partions d'être mises à jour
sudo udevadm settle  # Attend que toutes les partitions soient bien reconnues
sleep 2 # on laisse le temps aux infos de partions d'être mises à jour

echo "🧠 Configuration de l'impersistance (tmpfs en RAM)..."
mount -t tmpfs none /mnt -o size=2G,mode=755
mkdir -p /mnt/{boot,nix,persist,home,swap}

echo "🔗 Montages des volumes..."
mount "$PART_BOOT" "/mnt/boot"
mount "$PART_BTRFS" "/mnt/nix" -o subvol=@nix,noatime,compress=zstd,ssd,discard=async
mount "$PART_BTRFS" "/mnt/persist" -o subvol=@persist,noatime,compress=zstd,ssd,discard=async
mount "$PART_BTRFS" "/mnt/home" -o subvol=@home,noatime,compress=zstd,ssd,discard=async
mount "$PART_BTRFS" "/mnt/swap" -o subvol=@swap,noatime,ssd

echo -e "\n✅ Disque prêt et monté dans /mnt"
