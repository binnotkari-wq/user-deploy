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

TARGET_MOUNT="/mnt"
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
    mount "$PART_BTRFS" "$TARGET_MOUNT"
    
    # En mode REINSTALL, on supprime ce qui n'est pas précieux
    if [[ "$SCENARIO" == "REINSTALL" ]]; then
        for sub in @nix @persist @swap; do
            btrfs subvolume delete "$TARGET_MOUNT/$sub" 2>/dev/null || true
        done
    fi

    # On crée ce qui manque (WIPE créera tout, REINSTALL créera les 3 supprimés, @home reste)
    [[ ! -d "$TARGET_MOUNT/@nix" ]]     && btrfs subvolume create "$TARGET_MOUNT/@nix"
    [[ ! -d "$TARGET_MOUNT/@persist" ]] && btrfs subvolume create "$TARGET_MOUNT/@persist"
    [[ ! -d "$TARGET_MOUNT/@home" ]]    && btrfs subvolume create "$TARGET_MOUNT/@home"
    [[ ! -d "$TARGET_MOUNT/@swap" ]]    && btrfs subvolume create "$TARGET_MOUNT/@swap"
    
    umount "$TARGET_MOUNT"
fi

# --- 5. MONTAGES FINAUX (Commun à tous les modes) ---
echo "🧠 Configuration de l'impersistance (tmpfs en RAM)..."
mount -t tmpfs none "$TARGET_MOUNT" -o size=2G,mode=755
mkdir -p "$TARGET_MOUNT"/{boot,nix,persist,home,swap}

echo "🔗 Montages des volumes..."
mount "$PART_BOOT" "$TARGET_MOUNT/boot"
mount "$PART_BTRFS" "$TARGET_MOUNT/nix" -o subvol=@nix,noatime,compress=zstd,ssd,discard=async
mount "$PART_BTRFS" "$TARGET_MOUNT/persist" -o subvol=@persist,noatime,compress=zstd,ssd,discard=async
mount "$PART_BTRFS" "$TARGET_MOUNT/home" -o subvol=@home,noatime,compress=zstd,ssd,discard=async
mount "$PART_BTRFS" "$TARGET_MOUNT/swap" -o subvol=@swap,noatime,ssd
sleep 2 # on laisse le temps aux infos de partions d'être mises à jour
sudo partprobe /dev/$DISK # Rafraichi la détection de la nouvelle table de partitions
sleep 2 # on laisse le temps aux infos de partions d'être mises à jour
sudo udevadm settle  # Attend que toutes les partitions soient bien reconnues

echo -e "\n✅ Disque prêt et monté dans $TARGET_MOUNT"
