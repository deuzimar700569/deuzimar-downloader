#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

show_banner() {
    clear
    echo -e "${RED}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════════════╗"
    echo "  ║           DEUZIMAR DOWNLOADER - DESINSTALADOR           ║"
    echo "  ╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

confirm() {
    echo -e "${YELLOW}$1${NC}"
    read -p "(s/N): " resp
    [[ "$resp" == "s" || "$resp" == "S" ]]
}

remove_script() {
    echo -e "\n${BLUE}🗑️  Removendo script...${NC}"
    if [[ -f "$HOME/.local/bin/deuzimar-downloader" ]]; then
        rm -f "$HOME/.local/bin/deuzimar-downloader"
        echo -e "${GREEN}  ✓ $HOME/.local/bin/deuzimar-downloader${NC}"
    else
        echo -e "${YELLOW}  - Não encontrado${NC}"
    fi
}

remove_path() {
    echo -e "\n${BLUE}🔧 Limpando PATH do .bashrc/.zshrc...${NC}"
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [[ -f "$rc" ]]; then
            sed -i '/deuzimar-downloader/d' "$rc" 2>/dev/null
            sed -i '\|\.local/bin|d' "$rc" 2>/dev/null
            echo -e "${GREEN}  ✓ Limpo: $rc${NC}"
        fi
    done
}

remove_ytdlp() {
    if confirm "${YELLOW}🗑️  Remover yt-dlp e curl_cffi? (pode afetar outros programas)"; then
        echo -e "${BLUE}Removendo yt-dlp e curl_cffi...${NC}"
        if command -v pip3 &>/dev/null; then
            pip3 uninstall yt-dlp curl_cffi -y 2>/dev/null \
                && echo -e "${GREEN}  ✓ yt-dlp e curl_cffi removidos${NC}" \
                || echo -e "${YELLOW}  - Falha ao remover${NC}"
        fi
    fi
}

remove_deps() {
    if confirm "${YELLOW}🗑️  Remover ffmpeg e xclip? (cuidado: podem ser usados por outros programas)"; then
        echo -e "${BLUE}Removendo dependências...${NC}"
        sudo apt remove --purge -y ffmpeg xclip 2>/dev/null
        sudo apt autoremove --purge -y 2>/dev/null
        echo -e "${GREEN}  ✓ ffmpeg e xclip removidos${NC}"
    fi
}

remove_repo() {
    local repo_dir="$(cd "$(dirname "$0")" && pwd)"
    if [[ "$repo_dir" == "$HOME/deuzimar-downloader" || "$repo_dir" == "$(pwd)" ]]; then
        if confirm "${RED}🗑️  Remover também o diretório do repositório ($repo_dir)?${NC}"; then
            cd "$HOME" || return
            rm -rf "$repo_dir"
            echo -e "${GREEN}  ✓ Repositório removido${NC}"
        fi
    fi
}

show_summary() {
    echo -e "\n${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${GREEN}✅ Desinstalação concluída!${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${YELLOW}Para remover completamente, manualmente:${NC}"
    echo -e "  rm -rf ~/deuzimar-downloader"
    echo -e "  sudo apt remove yt-dlp ffmpeg xclip"
    echo -e "\n${CYAN}Pressione ENTER para sair...${NC}"
    read
}

main() {
    show_banner
    echo -e "${RED}⚠️  Isso removerá o Deuzimar Downloader do seu sistema.${NC}"
    echo -e "${YELLOW}O que será removido:${NC}"
    echo "  • Script: ~/.local/bin/deuzimar-downloader"
    echo "  • Entradas no PATH (.bashrc/.zshrc)"
    echo "  • (opcional) yt-dlp, ffmpeg, xclip"
    echo "  • (opcional) Diretório do repositório"
    echo ""

    if ! confirm "${RED}Tem certeza que deseja desinstalar?${NC}"; then
        echo -e "\n${GREEN}Desinstalação cancelada.${NC}"
        exit 0
    fi

    remove_script
    remove_path
    remove_ytdlp
    remove_deps
    remove_repo

    show_summary
}

main "$@"
