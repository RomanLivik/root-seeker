#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}   RootSeeker: Linux PrivEsc Auditor v1.1         ${NC}"
echo -e "${BLUE}==================================================${NC}"

echo -e "\n${YELLOW}[*] System Information${NC}"
[ -f /etc/os-release ] && OS=$(grep PRETTY_NAME /etc/os-release | cut -d'=' -f2- | tr -d '\"') || OS="Unknown"
echo -e "OS: $OS"
echo -e "Kernel: $(uname -r)"
echo -e "User: $(whoami) (ID: $(id -u))"
echo -e "Hostname: $(hostname)"

# File checker
echo -e "\n${YELLOW}[*] Checking Sensitive Files Permissions${NC}"
check_file() {
    local file=$1
    if [ -w "$file" ]; then
        echo -e "${RED}[!!!] ALERT: $file is WRITABLE!${NC}"
    elif [ -r "$file" ]; then
        if [[ "$file" == "/etc/passwd" || "$file" == "/etc/group" ]]; then
            echo -e "${YELLOW}[!] $file is readable (Normal, but check for extra users)${NC}"
        else
            echo -e "${RED}[!] $file is readable!${NC}"
        fi
    fi
}

files=("/etc/shadow" "/etc/passwd" "/etc/sudoers" "/etc/group")
for f in "${files[@]}"; do check_file "$f"; done

# SUID-binaries search
echo -e "\n${YELLOW}[*] Searching for SUID Binaries${NC}"
echo -e "${BLUE}(Comparing with GTFOBins high-risk list)${NC}"

danger_list=("vim" "find" "python" "bash" "nano" "perl" "ruby" "base64" "cp" "mv" "nmap" "strace" "systemctl")
suid_files=$(find /usr/bin /usr/sbin -perm -4000 -type f 2>/dev/null)

if [ -z "$suid_files" ]; then
    echo "[-] No SUID binaries found in standard paths."
else
    for suid in $suid_files; do
        filename=$(basename "$suid")
        is_danger=false
        for danger in "${danger_list[@]}"; do
            if [ "$filename" == "$danger" ]; then
                echo -e "${RED}[!!!] DANGEROUS SUID: $suid${NC} -> https://gtfobins.github.io/gtfobins/$danger/"
                is_danger=true
                break
            fi
        done
        if [ "$is_danger" = false ]; then
            echo -e "${GREEN}[+] Common SUID: $suid${NC}"
        fi
    done
fi

# Capabilities
echo -e "\n${YELLOW}[*] Checking File Capabilities${NC}"
if command -v getcap >/dev/null 2>&1; then
    caps=$(getcap -r / 2>/dev/null)
    [ -z "$caps" ] && echo "[-] No interesting capabilities found." || echo "$caps"
else
    echo "[-] 'getcap' utility not found."
fi

# World-Writable
echo -e "\n${YELLOW}[*] World-Writable Directories (Excluding /proc and /sys)${NC}"

ww_dirs=$(find / -type d \( -perm -0002 -a ! -perm -1000 \) -prune -o -path /proc -prune -o -path /sys -prune -o -path /dev -prune -print 2>/dev/null | head -n 10)
if [ ! -z "$ww_dirs" ]; then
    echo -e "${PURPLE}Top 10 world-writable directories found:${NC}"
    echo "$ww_dirs"
else
    echo "[-] No suspicious world-writable directories found."
fi

# Sudo checker
echo -e "\n${YELLOW}[*] Checking Sudo Privileges${NC}"
if command -v sudo >/dev/null 2>&1; then
    sudo_output=$(sudo -ln 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[+] Sudo permissions found:${NC}"
        echo "$sudo_output"
    else
        echo "[-] No passwordless sudo found."
    fi
else
    echo "[-] Sudo not installed."
fi

# 7. Search users without password
echo -e "\n${YELLOW}[*] Checking users with empty passwords${NC}"
empty_users=$(awk -F: '($2 == "") {print $1}' /etc/passwd 2>/dev/null)
[ -z "$empty_users" ] && echo "[-] No users with empty passwords." || echo -e "${RED}[!] Users with empty passwords: $empty_users${NC}"

echo -e "\n${BLUE}==================================================${NC}"
echo -e "${BLUE}   Audit Complete. Check findings above.          ${NC}"
echo -e "${BLUE}==================================================${NC}"
