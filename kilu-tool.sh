#!/bin/bash

# Tor VPN Setup Script for BlackArch Linux
# This script configures transparent proxy through Tor

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root${NC}"
   exit 1
fi

# Tor configuration
TOR_UID=$(id -u debian-tor 2>/dev/null || id -u tor 2>/dev/null)
TRANS_PORT="9040"
DNS_PORT="5353"
VIRT_ADDR="10.192.0.0/10"
NON_TOR="127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"

# Functions
print_status() {
    echo -e "${GREEN}[*]${NC} $1"
}

print_error() {
    echo -e "${RED}[!]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

install_tor() {
    print_status "Installing Tor..."
    if ! command -v tor &> /dev/null; then
        pacman -S tor --noconfirm
    else
        print_status "Tor is already installed"
    fi
}

backup_configs() {
    print_status "Backing up configurations..."
    cp /etc/tor/torrc /etc/tor/torrc.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null
    iptables-save > /etc/iptables/iptables.backup.$(date +%Y%m%d_%H%M%S) 2>/dev/null
}

configure_tor() {
    print_status "Configuring Tor..."
    
    cat > /etc/tor/torrc << EOF
# Tor VPN Configuration
VirtualAddrNetworkIPv4 $VIRT_ADDR
AutomapHostsOnResolve 1
TransPort $TRANS_PORT IsolateClientAddr IsolateClientProtocol IsolateDestAddr IsolateDestPort
DNSPort $DNS_PORT
EOF

    chmod 644 /etc/tor/torrc
}

setup_iptables() {
    print_status "Configuring iptables rules..."
    
    # Flush existing rules
    iptables -F
    iptables -t nat -F
    
    # Allow Tor user
    iptables -t nat -A OUTPUT -m owner --uid-owner $TOR_UID -j RETURN
    
    # Allow loopback
    iptables -t nat -A OUTPUT -o lo -j RETURN
    
    # Don't route local networks through Tor
    for NET in $NON_TOR; do
        iptables -t nat -A OUTPUT -d $NET -j RETURN
    done
    
    # Redirect DNS to Tor
    iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports $DNS_PORT
    iptables -t nat -A OUTPUT -p tcp --dport 53 -j REDIRECT --to-ports $DNS_PORT
    
    # Redirect all TCP through Tor
    iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports $TRANS_PORT
    
    # Accept established connections
    iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    
    # Allow Tor traffic
    iptables -A OUTPUT -m owner --uid-owner $TOR_UID -j ACCEPT
    
    # Allow loopback
    iptables -A OUTPUT -o lo -j ACCEPT
    
    # Drop everything else
    iptables -A OUTPUT -j REJECT
    
    # Save rules
    mkdir -p /etc/iptables
    iptables-save > /etc/iptables/iptables.rules
}

start_services() {
    print_status "Starting Tor service..."
    systemctl enable tor
    systemctl restart tor
    sleep 3
    
    if systemctl is-active --quiet tor; then
        print_status "Tor service is running"
    else
        print_error "Failed to start Tor service"
        exit 1
    fi
}

check_tor_connection() {
    print_status "Checking Tor connection..."
    sleep 2
    
    TOR_IP=$(curl -s --socks5 127.0.0.1:9050 https://check.torproject.org/api/ip 2>/dev/null | grep -o '"IsTor":true')
    
    if [[ -n "$TOR_IP" ]]; then
        print_status "Successfully connected to Tor network!"
        CURRENT_IP=$(curl -s https://api.ipify.org)
        echo -e "${GREEN}Your current IP: $CURRENT_IP${NC}"
    else
        print_warning "Could not verify Tor connection"
    fi
}

stop_tor_vpn() {
    print_status "Stopping Tor VPN..."
    systemctl stop tor
    
    # Flush iptables
    iptables -F
    iptables -t nat -F
    iptables -P INPUT ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -P FORWARD ACCEPT
    
    print_status "Tor VPN stopped and iptables rules cleared"
}

show_status() {
    echo -e "\n${GREEN}=== Tor VPN Status ===${NC}"
    systemctl status tor --no-pager -l
    echo -e "\n${GREEN}=== Current IP ===${NC}"
    curl -s https://api.ipify.org
    echo ""
}

# Main script
case "${1:-start}" in
    start)
        print_status "Starting Tor VPN setup..."
        install_tor
        backup_configs
        configure_tor
        setup_iptables
        start_services
        check_tor_connection
        print_status "Tor VPN setup complete!"
        ;;
    stop)
        stop_tor_vpn
        ;;
    restart)
        stop_tor_vpn
        sleep 2
        $0 start
        ;;
    status)
        show_status
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
