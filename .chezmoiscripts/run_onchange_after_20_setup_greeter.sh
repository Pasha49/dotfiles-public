#!/usr/bin/env bash
set -e

echo "==> [chezmoi] Checking greetd and Noctalia Greeter configuration..."

# Ensure target configuration directory exists
sudo mkdir -p /etc/greetd

# Configure /etc/greetd/config.toml only if it does not exist or lacks Noctalia session
if [ ! -f /etc/greetd/config.toml ] || ! grep -q "noctalia-greeter-session" /etc/greetd/config.toml; then
    echo "==> [chezmoi] Writing /etc/greetd/config.toml..."
    sudo tee /etc/greetd/config.toml > /dev/null << 'EOF'
[terminal]
vt = 1

[default_session]
command = "/usr/bin/noctalia-greeter-session"
user = "greeter"
EOF
else
    echo "==> [chezmoi] /etc/greetd/config.toml is already configured for Noctalia. Skipping."
fi

# Ensure greeter user belongs to video and input groups
if id "greeter" &> /dev/null; then
    sudo usermod -aG video,input greeter || true
fi

# Safely patch /etc/pam.d/greetd for gnome-keyring auto-unlock if not already present
if [ -f /etc/pam.d/greetd ]; then
    if ! grep -q "pam_gnome_keyring.so" /etc/pam.d/greetd; then
        echo "==> [chezmoi] Patching /etc/pam.d/greetd for gnome-keyring auto-unlock..."

        # Insert auth rule right after 'auth include system-local-login'
        sudo sed -i '/auth[[:space:]]\+include[[:space:]]\+system-local-login/a auth       optional     pam_gnome_keyring.so' /etc/pam.d/greetd

        # Append session rule to the end of the file
        echo "session    optional     pam_gnome_keyring.so auto_start" | sudo tee -a /etc/pam.d/greetd > /dev/null
    else
        echo "==> [chezmoi] /etc/pam.d/greetd already contains gnome-keyring rules. Skipping."
    fi
fi

# Provide a UWSM session entry for Wayland display managers
if command -v uwsm &> /dev/null; then
    echo "==> [chezmoi] Ensuring mango-uwsm.desktop entry exists..."
    sudo mkdir -p /usr/share/wayland-sessions
    sudo tee /usr/share/wayland-sessions/mango-uwsm.desktop > /dev/null << 'EOF'
[Desktop Entry]
Name=Mango (UWSM)
Comment=MangoWM managed by UWSM
Exec=uwsm start -S -s a -F /usr/share/wayland-sessions/mango.desktop
Type=Application
EOF
fi

# Ensure greetd service is enabled in systemd
echo "==> [chezmoi] Ensuring greetd.service is enabled..."
sudo systemctl enable greetd.service || true

echo "==> [chezmoi] Greeter setup complete."
