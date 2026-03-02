#!/usr/bin/env bash

# 1. Définition des chemins (Utilisation de $HOME pour la portabilité)
BIN_DIR="$HOME/.local/bin"
SERVICE_DIR="$HOME/.config/systemd/user"
SCRIPT_PATH="$BIN_DIR/mount-extra-disks.sh"
SERVICE_PATH="$SERVICE_DIR/mount-extra-disks.service"

echo "--- Configuration du montage automatique ---"

# 2. Création des répertoires si nécessaire
mkdir -p "$BIN_DIR"
mkdir -p "$SERVICE_DIR"

# 3. Création du script de montage (le contenu que tu as partagé)
cat << 'EOF' > "$SCRIPT_PATH"
#!/usr/bin/env bash
# mount-extra-disks.sh
username=$(whoami)
system_disk=$(lsblk -no NAME / | head -n1 | sed 's/[0-9]*//g')

for dev in $(lsblk -ndo NAME,TYPE | awk '$2=="disk"{print $1}' | grep -v "^${system_disk}"); do
    for part in $(lsblk -ln /dev/$dev | awk '$6=="part"{print $1}'); do
        device="/dev/$part"
        if ! mountpoint -q "/run/media/${username}/$(lsblk -no LABEL "$device" || echo "$part")" && ! mount | grep -q "$device"; then
            label=$(lsblk -no LABEL "$device")
            if [ -z "$label" ]; then label="$part"; fi
            
            mount_point="/run/media/${username}/${label}"
            mkdir -p "$mount_point"
            
            # Note : Sur Silverblue/NixOS, udisksctl est souvent plus fiable sans sudo
            # Mais on garde ta commande mount d'origine :
            mount -o users,nofail,noatime "$device" "$mount_point" 2>/dev/null || udisksctl mount -b "$device"
            
            chown -R "$username":users "$mount_point" 2>/dev/null
            echo "Tentative de montage : $device → $mount_point"
        fi
    done
done
EOF

chmod +x "$SCRIPT_PATH"
echo "[OK] Script créé dans $SCRIPT_PATH"

# 4. Création du service Systemd
cat << EOF > "$SERVICE_PATH"
[Unit]
Description=Monte tous les disques internes secondaires libres pour l'utilisateur
After=default.target

[Service]
Type=oneshot
ExecStart=$SCRIPT_PATH
RemainAfterExit=true

[Install]
WantedBy=default.target
EOF

echo "[OK] Service créé dans $SERVICE_PATH"

# 5. Activation du service
echo "--- Activation du service systemd (user-level) ---"
systemctl --user daemon-reload
systemctl --user enable mount-extra-disks.service
systemctl --user start mount-extra-disks.service

echo "Terminé ! Tes disques secondaires devraient maintenant être montés."



