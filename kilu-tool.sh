#!/bin/bash

# Animated Skull Terminal Art for BlackArch Linux
# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;90m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# Hide cursor
tput civis

# Trap to show cursor on exit
trap 'tput cnorm; exit' INT TERM EXIT

# Clear screen
clear

# Skull frames for blinking eyes animation
skull_frame1() {
cat << "EOF"
                    _,.-------.,_
                ,;~'             '~;,
              ,;                     ;,
             ;                         ;
            ,'                         ',
           ,;                           ;,
           ; ;      .           .      ; ;
           | ;   ______       ______   ; |
           |  `/~"     ~" . "~     "~\'  |
           |  ~  ,-~~~^~, | ,~^~~~-,  ~  |
            |   |        }:{        |   |
            |   l       / | \       !   |
            .~  (__,.--" .^. "--.,__)  ~.
            |     ---;' / | \ `;---     |
             \__.       \/^\/       .__/
              V| \                 / |V
               | |T~\___!___!___/~T| |
               | |`IIII_I_I_I_IIII'| |
               |  \,III I I I III,/  |
                \   `~~~~~~~~~~'    /
                 \   .       .   /
                   \.    ^    ./
                     ^~~~^~~~^
EOF
}

# Glitch effect frame
skull_glitch() {
cat << "EOF"
                    _,.-----▓▓.,_
                ,;~'    ░░       '~;,
              ,;      ▒▒             ;,
             ;           ░░            ;
            ,'        ▓▓               ',
           ,;            ░░             ;,
           ; ;      .    ▒▒     .      ; ;
           | ;   ___█__       ______   ; |
           |  `/~" ░░  ~" . "~     "~\'  |
           |  ~  ,-█~~^~, | ,~^~~~-,  ~  |
            |   |   ▓▓   }:{        |   |
            |   l    ░░ / | \       !   |
            .~  (__,.--" .^. "--.,__)  ~.
            |     ---█' / | \ `;---     |
             \__.   ░░   \/^\/       .__/
              V| \ ▒▒             / |V
               | |T~\___!___!___/~T| |
               | |`IIII▓I_I_I_IIII'| |
               |  \,III░I I I III,/  |
                \   `~~▒~~~~~~~'    /
                 \   .  ░    .   /
                   \.    ^    ./
                     ^~~~^~~~^
EOF
}

# Animation loop
animate_skull() {
    local cycles=0
    
    while [ $cycles -lt 3 ]; do
        # Clear and show frame 1
        clear
        echo -e "${RED}"
        skull_frame1
        echo -e "${NC}"
        display_info
        sleep 0.3
        
        # Clear and show frame 2 (blink)
        clear
        echo -e "${RED}"
        skull_frame2
        echo -e "${NC}"
        display_info
        sleep 0.15
        
        # Back to frame 1
        clear
        echo -e "${RED}"
        skull_frame1
        echo -e "${NC}"
        display_info
        sleep 0.8
        
        ((cycles++))
    done
    
    # Glitch effects
    for i in {1..5}; do
        clear
        echo -e "${MAGENTA}"
        skull_glitch
        echo -e "${NC}"
        display_info
        sleep 0.1
        
        clear
        echo -e "${RED}"
        skull_frame1
        echo -e "${NC}"
        display_info
        sleep 0.1
    done
    
    # Final display
    clear
    echo -e "${RED}"
    skull_frame1
    echo -e "${NC}"
    display_info
}

# Display system info
display_info() {
    echo -e "${CYAN}╔═══════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${WHITE}     BlackArch Penetration System     ${CYAN}║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}[+]${NC} User: ${YELLOW}$(whoami)${NC}"
    echo -e "${GREEN}[+]${NC} Hostname: ${YELLOW}$(hostname)${NC}"
    echo -e "${GREEN}[+]${NC} Kernel: ${YELLOW}$(uname -r)${NC}"
    echo -e "${GREEN}[+]${NC} Uptime: ${YELLOW}$(uptime -p 2>/dev/null || echo "N/A")${NC}"
    echo -e "${GREEN}[+]${NC} Date: ${YELLOW}$(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo ""
    echo -e "${RED}[!]${NC} ${GRAY}\"In the digital realm, we are all skulls...\"${NC}"
    echo -e "${MAGENTA}[*]${NC} Ready for exploitation..."
    echo ""
}

# Run animation
animate_skull

# Show cursor again
tput cnorm~~~~~~~~'    /
                 \   .       .   /
                   \.    ^    ./
                     ^~~~^~~~^
EOF
}

skull_frame2() {
cat << "EOF"
                    _,.-------.,_
                ,;~'             '~;,
              ,;                     ;,
             ;                         ;
            ,'                         ',
           ,;                           ;,
           ; ;      .           .      ; ;
           | ;   ______       ______   ; |
           |  `/~"     ~" . "~     "~\'  |
           |  ~  ,-~~~^~, | ,~^~~~-,  ~  |
            |   |        }:{        |   |
            |   l       / | \       !   |
            .~  (__,.--" .^. "--.,__)  ~.
            |     ---'  / | \  '---     |
             \__.       \/^\/       .__/
              V| \                 / |V
               | |T~\___!___!___/~T| |
               | |`IIII_I_I_I_IIII'| |
               |  \,III I I I III,/  |
                \   `~~
