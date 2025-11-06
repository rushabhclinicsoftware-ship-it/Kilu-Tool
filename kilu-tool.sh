#!/bin/bash

# BlackArch Linux Terminal Banner
# Add this to your ~/.bashrc or ~/.zshrc

# Colors
RED='\033[0;31m'
BRED='\033[1;31m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

clear

echo -e "${BRED}"
cat << "EOF"
    ██████╗ ██╗      █████╗  ██████╗██╗  ██╗ █████╗ ██████╗  ██████╗██╗  ██╗
    ██╔══██╗██║     ██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔══██╗██╔════╝██║  ██║
    ██████╔╝██║     ███████║██║     █████╔╝ ███████║██████╔╝██║     ███████║
    ██╔══██╗██║     ██╔══██║██║     ██╔═██╗ ██╔══██║██╔══██╗██║     ██╔══██║
    ██████╔╝███████╗██║  ██║╚██████╗██║  ██╗██║  ██║██║  ██║╚██████╗██║  ██║
    ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝
EOF
echo -e "${NC}"

echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}  Penetration Testing Distribution ${NC}${GRAY}|${NC} ${RED}https://blackarch.org${NC}"
echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GRAY}  User:${NC} $(whoami)@$(hostname)"
echo -e "${GRAY}  Date:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo -e "${GRAY}  Tools:${NC} $(pacman -Qq | grep blackarch | wc -l) BlackArch packages installed"
echo ""
echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
