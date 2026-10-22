#!/usr/bin/env bash
set -e

echo "==> [chezmoi] Setting up Noctalia Greeter..."

# Ensure noctalia-greeter-session binary is available
if ! command -v noctalia-greeter-session &> /dev/null; then
    echo "==> [chezmoi] WARNING: noctalia-greeter-session not found. Skipping greetd configuration."
    exit 0
fi

# Ensure target configuration directory exists
sudo mkdir -p /etc/greetd

# Generate /etc/greetd/config.toml as required by Noctalia documentation
echo "==> [chezmoi] Writing /etc/greetd/config.toml..."
sudo tee /etc/greetd/config.toml > /dev/null << 'EOF'
[default_session]
command = "/usr/bin/noctalia-greeter-session"
user = "greeter"
EOF

# Ensure the greeter user exists and has correct permissions
if id "greeter" &> /dev/null; then
    # Add greeter user to video and input groups if needed
    sudo usermod -aG video,input greeter || true
fi

# Enable greetd display manager service in systemd
echo "==> [chezmoi] Enabling greetd.service..."
sudo systemctl enable greetd.service

echo "==> [chezmoi] Noctalia Greeter setup complete."
