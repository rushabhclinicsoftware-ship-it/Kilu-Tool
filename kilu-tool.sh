#!/bin/bash

# BlackArch Advanced Wireless Tools Suite
# Enhanced with animations, logging, and advanced features
# Requires root privileges

# Colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Configuration
LOG_DIR="$HOME/wireless-logs"
CAPTURE_DIR="$HOME/wireless-captures"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/wireless_${TIMESTAMP}.log"

# Initialize directories
mkdir -p "$LOG_DIR" "$CAPTURE_DIR"

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}${BOLD}[!] This script must be run as root${NC}" 
   exit 1
fi

# Logging function
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Spinner animation
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c] " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Progress bar animation
progress_bar() {
    local duration=$1
    local message=$2
    local progress=0
    local bar_length=40
    
    echo -ne "${CYAN}${message}${NC}\n"
    while [ $progress -le 100 ]; do
        local filled=$((progress * bar_length / 100))
        local empty=$((bar_length - filled))
        printf "\r${GREEN}["
        printf "%${filled}s" | tr ' ' '█'
        printf "%${empty}s" | tr ' ' '░'
        printf "]${NC} ${WHITE}%3d%%${NC}" $progress
        progress=$((progress + 2))
        sleep $(echo "scale=3; $duration/50" | bc)
    done
    echo ""
}

# Animated banner
show_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
    ╔══════════════════════════════════════════════════════════════╗
    ║                                                              ║
    ║   ██████╗ ██╗      █████╗  ██████╗██╗  ██╗ █████╗ ██████╗   ║
    ║   ██╔══██╗██║     ██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔══██╗  ║
    ║   ██████╔╝██║     ███████║██║     █████╔╝ ███████║██████╔╝  ║
    ║   ██╔══██╗██║     ██╔══██║██║     ██╔═██╗ ██╔══██║██╔══██╗  ║
    ║   ██████╔╝███████╗██║  ██║╚██████╗██║  ██╗██║  ██║██║  ██║  ║
    ║   ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝  ║
    ║                                                              ║
    ║         ADVANCED WIRELESS PENETRATION TESTING SUITE         ║
    ║                                                              ║
    ╚══════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
    echo -e "${DIM}                    Version 2.0 | Enhanced Edition${NC}"
    echo -e "${DIM}                    Log: $LOG_FILE${NC}"
    echo ""
}

# Animated section header
section_header() {
    echo ""
    echo -e "${BLUE}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}${BOLD}║${NC} ${WHITE}$1${NC}"
    echo -e "${BLUE}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Success message with animation
success_msg() {
    echo -e "${GREEN}${BOLD}✓${NC} ${GREEN}$1${NC}"
    log_message "SUCCESS: $1"
}

# Error message with animation
error_msg() {
    echo -e "${RED}${BOLD}✗${NC} ${RED}$1${NC}"
    log_message "ERROR: $1"
}

# Warning message
warning_msg() {
    echo -e "${YELLOW}${BOLD}⚠${NC} ${YELLOW}$1${NC}"
    log_message "WARNING: $1"
}

# Info message
info_msg() {
    echo -e "${CYAN}${BOLD}ℹ${NC} ${CYAN}$1${NC}"
    log_message "INFO: $1"
}

# Check if a tool is installed
check_tool() {
    if ! command -v $1 &> /dev/null; then
        error_msg "$1 is not installed"
        echo -e "${YELLOW}Install with: pacman -S $1${NC}"
        return 1
    fi
    return 0
}

# System check with animation
system_check() {
    section_header "SYSTEM CHECK"
    
    local tools=("airmon-ng" "airodump-ng" "aireplay-ng" "aircrack-ng" "wash" "reaver" "iw" "iwconfig")
    local installed=0
    local total=${#tools[@]}
    
    for tool in "${tools[@]}"; do
        echo -ne "${CYAN}Checking ${tool}...${NC} "
        if command -v $tool &> /dev/null; then
            echo -e "${GREEN}✓ Installed${NC}"
            ((installed++))
        else
            echo -e "${RED}✗ Missing${NC}"
        fi
        sleep 0.1
    done
    
    echo ""
    echo -e "${WHITE}Status: ${installed}/${total} tools available${NC}"
    
    if [ $installed -eq $total ]; then
        success_msg "All required tools are installed"
    else
        warning_msg "Some tools are missing. Install with: pacman -S aircrack-ng reaver"
    fi
    
    log_message "System check completed: $installed/$total tools available"
}

# List wireless interfaces with details
list_interfaces() {
    section_header "WIRELESS INTERFACES"
    
    info_msg "Scanning for wireless interfaces..."
    sleep 0.5
    
    local interfaces=$(iw dev | grep Interface | awk '{print $2}')
    
    if [ -z "$interfaces" ]; then
        error_msg "No wireless interfaces found"
        return
    fi
    
    echo ""
    printf "${BOLD}%-15s %-20s %-10s %-15s${NC}\n" "INTERFACE" "MAC ADDRESS" "STATUS" "MODE"
    echo "────────────────────────────────────────────────────────────────"
    
    for iface in $interfaces; do
        local mac=$(cat /sys/class/net/$iface/address 2>/dev/null || echo "N/A")
        local state=$(cat /sys/class/net/$iface/operstate 2>/dev/null || echo "unknown")
        local mode=$(iw dev $iface info 2>/dev/null | grep type | awk '{print $2}' || echo "N/A")
        
        if [ "$state" == "up" ]; then
            printf "${GREEN}%-15s${NC} %-20s ${GREEN}%-10s${NC} %-15s\n" "$iface" "$mac" "$state" "$mode"
        else
            printf "${YELLOW}%-15s${NC} %-20s ${YELLOW}%-10s${NC} %-15s\n" "$iface" "$mac" "$state" "$mode"
        fi
    done
    
    log_message "Listed wireless interfaces"
}

# Enable monitor mode with animation
enable_monitor() {
    section_header "ENABLE MONITOR MODE"
    
    read -p "$(echo -e ${CYAN}Enter wireless interface name: ${NC})" interface
    
    if [ ! -d "/sys/class/net/$interface" ]; then
        error_msg "Interface $interface not found"
        return
    fi
    
    info_msg "Preparing to enable monitor mode on $interface"
    
    echo -e "${YELLOW}Killing interfering processes...${NC}"
    progress_bar 2 "Stopping network services"
    airmon-ng check kill > /dev/null 2>&1
    success_msg "Interfering processes terminated"
    
    echo ""
    info_msg "Enabling monitor mode..."
    progress_bar 2 "Configuring interface"
    
    airmon-ng start $interface > /dev/null 2>&1
    
    sleep 1
    
    if iw dev | grep -q "monitor"; then
        local mon_iface=$(iw dev | grep -A 1 "type monitor" | grep Interface | awk '{print $2}')
        success_msg "Monitor mode enabled on $mon_iface"
        log_message "Monitor mode enabled: $interface -> $mon_iface"
    else
        error_msg "Failed to enable monitor mode"
        log_message "Failed to enable monitor mode on $interface"
    fi
}

# Disable monitor mode
disable_monitor() {
    section_header "DISABLE MONITOR MODE"
    
    read -p "$(echo -e ${CYAN}Enter monitor interface name: ${NC})" interface
    
    info_msg "Disabling monitor mode on $interface"
    progress_bar 2 "Restoring interface"
    
    airmon-ng stop $interface > /dev/null 2>&1
    
    echo ""
    info_msg "Restarting NetworkManager..."
    systemctl start NetworkManager > /dev/null 2>&1
    
    success_msg "Monitor mode disabled"
    success_msg "NetworkManager restarted"
    log_message "Monitor mode disabled on $interface"
}

# Advanced network scan
scan_networks() {
    section_header "WIRELESS NETWORK SCANNER"
    
    read -p "$(echo -e ${CYAN}Enter monitor interface name: ${NC})" interface
    read -p "$(echo -e ${CYAN}Scan duration in seconds [60]: ${NC})" duration
    duration=${duration:-60}
    
    local output="$CAPTURE_DIR/scan_${TIMESTAMP}"
    
    info_msg "Starting network scan for $duration seconds"
    info_msg "Output: $output"
    warning_msg "Press Ctrl+C to stop scanning"
    
    echo ""
    log_message "Starting network scan on $interface for $duration seconds"
    
    timeout $duration airodump-ng -w "$output" --output-format csv $interface > /dev/null 2>&1 &
    local scan_pid=$!
    
    spinner $scan_pid
    
    if [ -f "${output}-01.csv" ]; then
        success_msg "Scan completed"
        echo ""
        info_msg "Processing results..."
        
        # Parse and display results
        awk -F',' 'NR>2 && $1 !~ /Station/ && $14 != "" {
            printf "%-20s | %-17s | Ch: %-2s | Pwr: %-3s | %s\n", 
            substr($14,2), $1, $4, $9, $6
        }' "${output}-01.csv" | head -20
        
        log_message "Network scan completed: ${output}-01.csv"
    else
        error_msg "Scan failed or no networks found"
    fi
}

# Capture handshake with advanced options
capture_handshake() {
    section_header "WPA/WPA2 HANDSHAKE CAPTURE"
    
    read -p "$(echo -e ${CYAN}Enter monitor interface: ${NC})" interface
    read -p "$(echo -e ${CYAN}Enter target BSSID: ${NC})" bssid
    read -p "$(echo -e ${CYAN}Enter target channel: ${NC})" channel
    read -p "$(echo -e ${CYAN}Output filename [handshake]: ${NC})" output
    output=${output:-handshake}
    
    local full_output="$CAPTURE_DIR/${output}_${TIMESTAMP}"
    
    info_msg "Target: $bssid on channel $channel"
    info_msg "Saving to: $full_output"
    warning_msg "Press Ctrl+C when handshake is captured"
    
    echo ""
    log_message "Starting handshake capture: $bssid ch:$channel -> $full_output"
    
    airodump-ng -c $channel --bssid $bssid -w "$full_output" $interface
    
    success_msg "Capture stopped"
    log_message "Handshake capture completed"
}

# Deauth attack with options
deauth_attack() {
    section_header "DEAUTHENTICATION ATTACK"
    
    read -p "$(echo -e ${CYAN}Enter monitor interface: ${NC})" interface
    read -p "$(echo -e ${CYAN}Enter target BSSID (AP): ${NC})" bssid
    read -p "$(echo -e ${CYAN}Enter client MAC (empty for broadcast): ${NC})" client
    read -p "$(echo -e ${CYAN}Number of packets [10]: ${NC})" count
    count=${count:-10}
    
    warning_msg "Initiating deauthentication attack"
    info_msg "Target AP: $bssid"
    
    if [ -z "$client" ]; then
        info_msg "Mode: Broadcast (all clients)"
        log_message "Deauth attack: $bssid (broadcast) x$count"
        aireplay-ng --deauth $count -a $bssid $interface
    else
        info_msg "Mode: Targeted client ($client)"
        log_message "Deauth attack: $bssid -> $client x$count"
        aireplay-ng --deauth $count -a $bssid -c $client $interface
    fi
    
    success_msg "Deauth attack completed"
}

# Crack WPA/WPA2 with progress
crack_wpa() {
    section_header "WPA/WPA2 PASSWORD CRACKER"
    
    read -p "$(echo -e ${CYAN}Enter capture file path (.cap): ${NC})" capfile
    read -p "$(echo -e ${CYAN}Enter wordlist path: ${NC})" wordlist
    
    if [ ! -f "$capfile" ]; then
        error_msg "Capture file not found: $capfile"
        return
    fi
    
    if [ ! -f "$wordlist" ]; then
        error_msg "Wordlist not found: $wordlist"
        return
    fi
    
    local word_count=$(wc -l < "$wordlist")
    info_msg "Capture file: $capfile"
    info_msg "Wordlist: $wordlist ($word_count words)"
    
    echo ""
    info_msg "Starting dictionary attack..."
    warning_msg "This may take a while depending on wordlist size"
    
    log_message "WPA crack started: $capfile with $wordlist"
    
    aircrack-ng -w "$wordlist" "$capfile"
    
    log_message "WPA crack completed"
}

# WPS scanner
wps_scan() {
    section_header "WPS VULNERABILITY SCANNER"
    
    read -p "$(echo -e ${CYAN}Enter monitor interface: ${NC})" interface
    read -p "$(echo -e ${CYAN}Scan duration in seconds [60]: ${NC})" duration
    duration=${duration:-60}
    
    info_msg "Scanning for WPS-enabled networks"
    info_msg "Duration: $duration seconds"
    warning_msg "Press Ctrl+C to stop"
    
    echo ""
    log_message "WPS scan started on $interface for $duration seconds"
    
    timeout $duration wash -i $interface
    
    success_msg "WPS scan completed"
    log_message "WPS scan completed"
}

# WPS attack
wps_attack() {
    section_header "WPS PIN ATTACK (REAVER)"
    
    read -p "$(echo -e ${CYAN}Enter monitor interface: ${NC})" interface
    read -p "$(echo -e ${CYAN}Enter target BSSID: ${NC})" bssid
    read -p "$(echo -e ${CYAN}Enter target channel: ${NC})" channel
    
    warning_msg "Starting WPS brute force attack"
    info_msg "Target: $bssid on channel $channel"
    info_msg "This attack can take several hours"
    
    echo ""
    log_message "WPS attack started: $bssid ch:$channel"
    
    reaver -i $interface -b $bssid -c $channel -vv
    
    log_message "WPS attack completed/stopped"
}

# View logs
view_logs() {
    section_header "VIEW LOGS"
    
    if [ -f "$LOG_FILE" ]; then
        info_msg "Current log file: $LOG_FILE"
        echo ""
        tail -n 50 "$LOG_FILE"
    else
        warning_msg "No logs found for this session"
    fi
    
    echo ""
    info_msg "All logs stored in: $LOG_DIR"
}

# Main menu with animation
main_menu() {
    while true; do
        show_banner
        
        echo -e "${BLUE}${BOLD}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}${BOLD}║${NC}  ${WHITE}${BOLD}MAIN MENU${NC}                                                    ${BLUE}${BOLD}║${NC}"
        echo -e "${BLUE}${BOLD}╠════════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${BLUE}${BOLD}║${NC}  ${CYAN}1.${NC}  System Check                                             ${BLUE}${BOLD}║${NC}"
        echo -e "${BLUE}${BOLD}║${NC}  ${CYAN}2.${NC}  List Wireless Interfaces                                 ${BLUE}${BOLD}║${NC}"
        echo -e "${BLUE}${BOLD}║${NC}  ${CYAN}3.${NC}  Enable Monitor Mode                                      ${BLUE}${BOLD}║${NC}"
        echo -e "${BLUE}${BOLD}║${NC}  ${CYAN}4.${NC}  Disable Monitor Mode                                     ${BLUE}${BOLD}║${NC}"
        echo -e "${BLUE}${BOLD}║${NC}  ${CYAN}5.${NC}  Scan Wireless Networks                                   ${BLUE}${BOLD}║${NC}"
        echo -e "${BLUE}${BOLD}║${NC}  ${CYAN}6.${NC}  Capture WPA/WPA2 Handshake                               ${BLUE}${BOLD}║${NC}"
        echo -e "${BLUE}${BOLD}║${NC}  ${CYAN}7.${NC}  Deauthentication Attack                                  ${BLUE}${BOLD}║${NC}"
        echo -e "${BLUE}${BOLD}║${NC}  ${CYAN}8.${NC}  Crack WPA/WPA2 Password                                  ${BLUE}${BOLD}║${NC}"
        echo -e "${BLUE}${BOLD}║${NC}  ${CYAN}9.${NC}  Scan for WPS Networks                                    ${BLUE}${BOLD}║${NC}"
        echo -e "${BLUE}${BOLD}║${NC}  ${CYAN}10.${NC} WPS PIN Attack (Reaver)                                  ${BLUE}${BOLD}║${NC}"
        echo -e "${BLUE}${BOLD}║${NC}  ${CYAN}11.${NC} View Logs                                                ${BLUE}${BOLD}║${NC}"
        echo -e "${BLUE}${BOLD}║${NC}  ${CYAN}0.${NC}  Exit                                                     ${BLUE}${BOLD}║${NC}"
        echo -e "${BLUE}${BOLD}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        read -p "$(echo -e ${WHITE}${BOLD}Select option: ${NC})" choice
        
        case $choice in
            1) system_check ;;
            2) list_interfaces ;;
            3) check_tool airmon-ng && enable_monitor ;;
            4) check_tool airmon-ng && disable_monitor ;;
            5) check_tool airodump-ng && scan_networks ;;
            6) check_tool airodump-ng && capture_handshake ;;
            7) check_tool aireplay-ng && deauth_attack ;;
            8) check_tool aircrack-ng && crack_wpa ;;
            9) check_tool wash && wps_scan ;;
            10) check_tool reaver && wps_attack ;;
            11) view_logs ;;
            0)
                section_header "EXITING"
                info_msg "Logs saved to: $LOG_FILE"
                success_msg "Thank you for using BlackArch Wireless Tools"
                log_message "Session ended"
                exit 0
                ;;
            *)
                error_msg "Invalid option"
                ;;
        esac
        
        echo ""
        read -p "$(echo -e ${DIM}Press Enter to continue...${NC})"
    done
}

# Initialize and run
log_message "Session started"
main_menu