#!/bin/bash
set -euo pipefail

[ "$EUID" -ne 0 ] && exec sudo bash "$0" "$@"

CPU_SERVICE="/etc/systemd/system/bugtux-cpu.service"
SYSCTL_FILE="/etc/sysctl.d/99-bugtux-perf.conf"
DNS_CONF="/etc/NetworkManager/conf.d/99-bugtux-dns.conf"

declare -A DNS_LABEL=( [0]="Cloudflare Malware Block" [1]="AdGuard" )
declare -A DNS4=(      [0]="1.1.1.2 1.0.0.2"          [1]="94.140.14.14 94.140.15.15" )
declare -A DNS6=(      [0]="2606:4700:4700::1112 2606:4700:4700::1002" [1]="2a10:50c0::ad1:ff 2a10:50c0::ad2:ff" )

G='\033[0;32m'
Y='\033[1;33m'
C='\033[0;36m'
B='\033[1;34m'
BLD='\033[1m'
N='\033[0m'

ok()   { echo -e "${G}[✓]${N} $*"; }
skip() { echo -e "${Y}[~]${N} $* — já aplicado, pulando."; }
step() { echo -e "${C}[>]${N} $*"; }

header() {
    echo -e "\n${C}══════════════════════════════════════${N}"
    echo -e "${C}   BugTux — CachyOS Performance Elite  ${N}"
    echo -e "${C}══════════════════════════════════════${N}\n"
}

content_matches() {
    [ -f "$1" ] && [ "$(cat "$1")" = "$2" ]
}

# ── Performance ────────────────────────────────────────────────────────────────

apply_cpu() {
    read -r -d '' content << 'EOF' || true
[Unit]
Description=BugTux CPU Performance Enforcer
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor'
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
    if systemctl is-enabled --quiet bugtux-cpu.service 2>/dev/null && content_matches "$CPU_SERVICE" "$content"; then
        CPU_MSG="$(skip "CPU Governor" 2>&1)"
        return
    fi
    systemctl mask --quiet power-profiles-daemon.service tlp.service 2>/dev/null || true
    printf '%s\n' "$content" > "$CPU_SERVICE"
    systemctl daemon-reload
    systemctl enable --now --quiet bugtux-cpu.service
    CPU_MSG="$(ok "CPU Governor → performance" 2>&1)"
}

apply_sysctl() {
    read -r -d '' content << 'EOF' || true
vm.swappiness = 10
vm.vfs_cache_pressure = 50
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
EOF
    if content_matches "$SYSCTL_FILE" "$content"; then
        SYSCTL_MSG="$(skip "Parâmetros de kernel" 2>&1)"
        return
    fi
    printf '%s\n' "$content" > "$SYSCTL_FILE"
    sysctl --system -q
    SYSCTL_MSG="$(ok "Kernel sysctl aplicado" 2>&1)"
}

# ── DNS ────────────────────────────────────────────────────────────────────────

select_dns() {
    local choice=0 key seq
    while true; do
        clear >&2
        echo -e "${B}Selecione o provedor de DNS:${N}\n" >&2
        if [ $choice -eq 0 ]; then
            echo -e "  ${BLD}${G}→ ${DNS_LABEL[0]} ←${N}          ${DNS_LABEL[1]}" >&2
        else
            echo -e "    ${DNS_LABEL[0]}          ${BLD}${G}→ ${DNS_LABEL[1]} ←${N}" >&2
        fi
        echo -e "\n${Y}← → navegar  |  Enter confirma  |  Ctrl+C cancela${N}" >&2
        read -rsn1 key
        if [ "$key" = $'\x1b' ]; then
            read -rsn2 -t 0.1 seq 2>/dev/null || true
            case $seq in '[D') choice=0 ;; '[C') choice=1 ;; esac
        elif [ -z "$key" ]; then
            echo "$choice"
            return
        fi
    done
}

apply_dns() {
    local idx="$1"
    local d4="${DNS4[$idx]}" d6="${DNS6[$idx]}"
    local d4csv="${d4// /,}" d6csv="${d6// /,}"
    local conf_content="[global-dns-domain-*]
servers=${d4csv},${d6csv}"
    if content_matches "$DNS_CONF" "$conf_content"; then
        DNS_MSG="$(skip "DNS (${DNS_LABEL[$idx]})" 2>&1)"
        return
    fi
    mkdir -p "$(dirname "$DNS_CONF")"
    printf '%s\n' "$conf_content" > "$DNS_CONF"
    while IFS= read -r conn; do
        [ -z "$conn" ] || [ "$conn" = "lo" ] && continue
        nmcli connection modify "$conn" \
            ipv4.ignore-auto-dns yes \
            ipv4.dns "$d4" \
            ipv6.ignore-auto-dns yes \
            ipv6.dns "$d6" 2>/dev/null || true
    done < <(nmcli -g NAME connection show)
    systemctl restart NetworkManager
    DNS_MSG="$(ok "DNS ${DNS_LABEL[$idx]} injetado (${d4csv})" 2>&1)"
}

# ── Main ───────────────────────────────────────────────────────────────────────

trap 'clear; exit 0' INT

CPU_MSG="" SYSCTL_MSG="" DNS_MSG=""

apply_cpu
apply_sysctl
dns_idx=$(select_dns)
apply_dns "$dns_idx"

clear
header
echo -e "$CPU_MSG"
echo -e "$SYSCTL_MSG"
echo -e "$DNS_MSG"
echo -e "\n${G}══ Sistema no pico de desempenho. ══${N}\n"
read -n 1 -s -r -p "Pressione qualquer tecla para sair..." && clear
