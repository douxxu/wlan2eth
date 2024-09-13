#!/bin/bash

set -e

ascii() {
    echo """
⠀⠀⠀⠀⠀⠀ ⢀⣤⣴⣶⣶⣦⣤⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⣠⣤⣴⣿⣿⠟⠛⠛⠻⢿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢀⣴⣿⣿⠿⠿⠟⠀⠀⠀⠀⠀⠀⢻⣿⣷⣀⡀⠀⠀⠀⠀⠀
⠀⠀⠀⣾⣿⡟⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⣿⣷⡄⠀⠀⠀
⠀⠀⠀⢿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⠀⠀⠀
⠀⠀⠀⠈⢿⣿⣿⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣿⣿⠟⠀⠀⠀
⠀⠀⠀⠀⠀⠈⠙⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠋⠁⠀⠀⠀"""
}

show_help() {
    echo "Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -h, --help        Show this help message"
    echo "  -r, --ip-range    Specify the DHCP range for eth0 (e.g., 192.168.0.50,192.168.0.150)"
    echo
}

iprange="192.168.0.2,192.168.0.255"

# Process command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help) show_help; exit 0 ;;
        -r|--ip-range) iprange="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; show_help; exit 1 ;;
    esac
    shift
done

# Display ASCII art and warning message
ascii
echo "WARNING: This script will permanently modify the network configuration of your Raspberry Pi."
echo "It will set a static IP for eth0, configure dnsmasq for DHCP, and set up IP forwarding."
read -p "Do you want to continue? (Y/n) " -r
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

# Update and install packages
echo "Updating system and installing required packages..."
sudo apt update
sudo apt upgrade -y
sudo apt install -y dnsmasq hostapd iptables-persistent

echo "Configuring Wi-Fi to share over Ethernet..."

# Configure dhcpcd
echo "Configuring /etc/dhcpcd.conf..."
sudo tee /etc/dhcpcd.conf > /dev/null <<EOF
# Static IP address for eth0
interface eth0
static ip_address=192.168.0.1/24
nohook wpa_supplicant
EOF

# Configure dnsmasq
echo "Configuring /etc/dnsmasq.conf..."
sudo tee /etc/dnsmasq.conf > /dev/null <<EOF
# Listen on eth0 interface
interface=eth0
# DHCP range for eth0
dhcp-range=${iprange},12h
EOF

# Enable IP forwarding
echo "Enabling IP forwarding..."
sudo tee -a /etc/sysctl.conf > /dev/null <<EOF
net.ipv4.ip_forward=1
EOF

sudo sysctl -p

# Set up iptables rules
echo "Setting up iptables rules..."
sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sudo iptables -A FORWARD -i wlan0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i eth0 -o wlan0 -j ACCEPT

# Save iptables rules
sudo sh -c "iptables-save > /etc/iptables/rules.v4"

# Restart services
echo "Restarting services..."
sudo systemctl restart dhcpcd
sudo systemctl restart dnsmasq

# Completion message
echo "Configuration complete! Your Raspberry Pi is now sharing its Wi-Fi connection over Ethernet."
