#!/usr/bin/env bash
# Limpeza: Kernels + Órfãos + Cache DNF + Flatpaks + Cache Plasma

set -euo pipefail

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

HAS_WORK=false

confirm() {
    local prompt="$1"
    local choice=0
    while true; do
        clear
        echo -e "${BLUE}$prompt${NC}"
        echo ""
        if [ $choice -eq 0 ]; then
            echo -e "  ${BOLD}${GREEN}→ SIM ←${NC}          ${WHITE}NÃO${NC}"
        else
            echo -e "    ${WHITE}SIM${NC}          ${BOLD}${RED}→ NÃO ←${NC}"
        fi
        echo ""
        echo -e "${YELLOW}← → navegar | Enter confirma | Ctrl+C cancela${NC}"
        read -rsn1 key
        if [ "$key" = $'\x1b' ]; then
            read -rsn2 -t 0.1 key 2>/dev/null
            case $key in
                '[D') choice=0 ;;
                '[C') choice=1 ;;
            esac
        elif [ "$key" = "" ]; then
            [ $choice -eq 0 ] && return 0
            return 1
        fi
    done
}

print_header() {
    clear
    echo -e "${BLUE}Clean Kernel - Nobara 2026${NC}"
    echo -e "${WHITE}Kernels + Órfãos + Cache DNF + Flatpaks + Plasma${NC}"
    echo ""
}

clean_old_kernels() {
    local old_kernels=$(dnf repoquery --installonly --latest-limit=-1 -q 2>/dev/null || echo "")
    
    if [ -z "$old_kernels" ]; then
        echo -e "${WHITE}Nenhum kernel antigo encontrado${NC}"
        return
    fi
    
    if ! confirm "Remover kernels antigos?"; then
        echo -e "${RED}Operação cancelada${NC}"
        return
    fi
    
    clear
    local limit=-2
    if confirm "Manter APENAS o kernel atual? (NÃO = atual + anterior)"; then
        limit=-1
    fi
    
    clear
    if ! confirm "CONFIRMA remoção permanente dos kernels antigos?"; then
        echo -e "${RED}Operação cancelada${NC}"
        return
    fi
    
    echo -e "${WHITE}Removendo kernels antigos...${NC}"
    old_kernels=$(dnf repoquery --installonly --latest-limit="$limit" -q 2>/dev/null || echo "")
    
    if [ -n "$old_kernels" ]; then
        dnf remove -y $old_kernels
        HAS_WORK=true
        echo -e "${GREEN}✓ Kernels antigos removidos${NC}"
    fi
}

clean_orphan_packages() {
    echo -e "${WHITE}Verificando pacotes órfãos...${NC}"
    
    local orphans=$(dnf autoremove -y --assumeno 2>/dev/null | grep -A 999 "Removing:" | grep -v "Removing:" | awk '{print $1}' | grep -v '^$' || echo "")
    
    if [ -z "$orphans" ]; then
        echo -e "${WHITE}Nenhum pacote órfão encontrado${NC}"
        return
    fi
    
    if ! confirm "Remover pacotes órfãos?"; then
        echo -e "${RED}Operação cancelada${NC}"
        return
    fi
    
    echo -e "${WHITE}Removendo pacotes órfãos...${NC}"
    dnf autoremove -y
    HAS_WORK=true
    echo -e "${GREEN}✓ Pacotes órfãos removidos${NC}"
}

clean_dnf_cache() {
    if ! confirm "Limpar cache DNF?"; then
        echo -e "${RED}Operação cancelada${NC}"
        return
    fi
    
    echo -e "${WHITE}Limpando cache DNF...${NC}"
    dnf clean all
    HAS_WORK=true
    echo -e "${GREEN}✓ Cache DNF limpo${NC}"
}

clean_flatpak_unused() {
    if ! command -v flatpak &>/dev/null; then
        echo -e "${WHITE}Flatpak não instalado. Pulando${NC}"
        return
    fi
    
    echo -e "${WHITE}Limpando Flatpaks não usados...${NC}"
    
    if flatpak uninstall --unused -y 2>/dev/null; then
        HAS_WORK=true
        echo -e "${GREEN}✓ Flatpaks não usados removidos${NC}"
    else
        echo -e "${YELLOW}Nenhum Flatpak não usado encontrado${NC}"
    fi
}

clean_plasma_cache() {
    if ! confirm "Limpar cache Plasma? (plasmashell + kactivitymanagerd)"; then
        echo -e "${RED}Operação cancelada${NC}"
        return
    fi
    
    echo -e "${WHITE}Limpando cache Plasma...${NC}"
    
    local cache_dirs=(
        "$HOME/.cache/plasmashell"
        "$HOME/.cache/kactivitymanagerd"
    )
    
    for cache_dir in "${cache_dirs[@]}"; do
        if [ -d "$cache_dir" ]; then
            rm -rf "$cache_dir"
        fi
    done
    
    HAS_WORK=true
    echo -e "${GREEN}✓ Cache Plasma limpo${NC}"
}

main() {
    print_header
    
    clean_old_kernels
    echo ""
    
    clean_orphan_packages
    echo ""
    
    clean_dnf_cache
    echo ""
    
    clean_flatpak_unused
    echo ""
    
    clean_plasma_cache
    echo ""
    
    if [ "$HAS_WORK" = true ]; then
        echo -e "${GREEN}✓ Limpeza concluída com sucesso${NC}"
    else
        echo -e "${YELLOW}Nenhuma limpeza realizada${NC}"
    fi
    
    echo ""
    read -n1 -s -r -p "Pressione qualquer tecla para sair..."
    clear
}

trap 'echo -e "\n${RED}Erro detectado${NC}"; exit 1' ERR

main
