#!/bin/bash

# ======================================================
# Instalador do Deuzimar Downloader
# Autor: Deuzimar
# Licença: MIT
# ======================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}"
echo "  ╔══════════════════════════════════════════════════════════╗"
echo "  ║                                                          ║"
echo "  ║     ██████╗ ███████╗██╗   ██╗███████╗██╗███╗   ███╗      ║"
echo "  ║     ██╔══██╗██╔════╝██║   ██║╚══███╔╝██║████╗ ████║      ║"
echo "  ║     ██║  ██║█████╗  ██║   ██║  ███╔╝ ██║██╔████╔██║      ║"
echo "  ║     ██║  ██║██╔══╝  ██║   ██║ ███╔╝  ██║██║╚██╔╝██║      ║"
echo "  ║     ██████╔╝███████╗╚██████╔╝███████╗██║██║ ╚═╝ ██║      ║"
echo "  ║     ╚═════╝ ╚══════╝ ╚═════╝ ╚══════╝╚═╝╚═╝     ╚═╝      ║"
echo "  ║                                                          ║"
echo "  ║           🎥  DOWNLOADER DE VÍDEOS  🎵                    ║"
echo "  ║                 CRIADO POR: DEUZIMAR                     ║"
echo "  ║                                                          ║"
echo "  ╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${GREEN}🚀 Iniciando instalação do Deuzimar Downloader...${NC}\n"

if [[ $EUID -ne 0 ]]; then
   echo -e "${YELLOW}⚠️  Este instalador precisa de privilégios sudo para instalar dependências.${NC}"
   echo -e "${CYAN}🔐 Por favor, digite sua senha quando solicitado.${NC}\n"
fi

install_if_missing() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${YELLOW}📦 Instalando $2...${NC}"
        sudo apt update -qq
        sudo apt install -y $2
    else
        echo -e "${GREEN}✅ $2 já está instalado.${NC}"
    fi
}

echo -e "${BLUE}🔍 Verificando dependências necessárias...${NC}\n"

if ! command -v yt-dlp &> /dev/null; then
    echo -e "${YELLOW}📦 Instalando yt-dlp via pip3...${NC}"
    sudo apt install -y python3-pip
    pip3 install yt-dlp --break-system-packages 2>/dev/null || pip3 install yt-dlp
else
    echo -e "${GREEN}✅ yt-dlp já está instalado.${NC}"
    echo -e "${YELLOW}🔃 Atualizando yt-dlp para a versão mais recente...${NC}"
    pip3 install --upgrade yt-dlp --break-system-packages 2>/dev/null || pip3 install --upgrade yt-dlp
fi

install_if_missing ffmpeg ffmpeg
install_if_missing curl curl
install_if_missing xclip xclip

echo -e "\n${BLUE}📁 Criando diretório de scripts...${NC}"
mkdir -p ~/.local/bin

# Copia o script principal (certifique-se que ele está no mesmo diretório que install.sh)
if [[ -f "deuzimar-downloader.sh" ]]; then
    cp deuzimar-downloader.sh ~/.local/bin/deuzimar-downloader
    chmod +x ~/.local/bin/deuzimar-downloader
else
    echo -e "${RED}❌ Arquivo deuzimar-downloader.sh não encontrado. Abortando.${NC}"
    exit 1
fi

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "${YELLOW}🔧 Adicionando ~/.local/bin ao PATH...${NC}"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
    export PATH="$HOME/.local/bin:$PATH"
fi

echo -e "\n${GREEN}✨ Instalação concluída com sucesso!${NC}"
echo -e "${CYAN}▶️  Para executar o Deuzimar Downloader, digite:${NC} ${BOLD}deuzimar-downloader${NC}"
echo -e "${CYAN}📖 Para ver o manual de uso (inclui como instalar), digite:${NC} ${BOLD}deuzimar-downloader${NC} e escolha opção 2\n"

read -p "Deseja executar o Deuzimar Downloader agora? (s/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    ~/.local/bin/deuzimar-downloader
fi
