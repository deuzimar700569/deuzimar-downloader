#!/bin/bash

# ======================================================
# Deuzimar Downloader - Baixe vídeos em alta qualidade
# Autor: Deuzimar
# Versão: 1.1
# Licença: MIT
# ======================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
NC='\033[0m'

show_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════════════════════════════════════════╗"
    echo "  ║                                                                                      ║"
    echo "  ║     ██████╗ ███████╗██╗   ██╗███████╗██╗███╗   ███╗ █████╗ ██████╗                   ║"
    echo "  ║     ██╔══██╗██╔════╝██║   ██║╚══███╔╝██║████╗ ████║██╔══██╗██╔══██╗                  ║"
    echo -e "  ║     ${MAGENTA}██║  ██║█████╗  ██║   ██║  ███╔╝ ██║██╔████╔██║███████║██████╔╝${CYAN}                  ║"
    echo "  ║     ██║  ██║██╔══╝  ██║   ██║ ███╔╝  ██║██║╚██╔╝██║██╔══██║██╔══██╗                  ║"
    echo "  ║     ██████╔╝███████╗╚██████╔╝███████╗██║██║ ╚═╝ ██║██║  ██║██║  ██║                  ║"
    echo "  ║     ╚═════╝ ╚══════╝ ╚═════╝ ╚══════╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝                  ║"
    echo "  ║                                                                                      ║"
    echo -e "  ║                    🎬 ${WHITE}DOWNLOADER DE VÍDEOS - MELHOR QUALIDADE${CYAN} 🎬                  ║"
    echo -e "  ║                              ${GREEN}C R I A D O   P O R :   D E U Z I M A R${CYAN}                     ║"
    echo "  ║                                                                                      ║"
    echo "  ╚══════════════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_manual() {
    show_banner
    echo -e "${WHITE}${UNDERLINE}📖 MANUAL DE USO - Deuzimar Downloader${NC}\n"
    echo -e "${GREEN}🔹 O que faz:${NC}"
    echo "   Baixa vídeos de várias plataformas (YouTube, Vimeo, Twitter, etc.)"
    echo "   na melhor qualidade possível (vídeo HD/4K + áudio original)."
    echo -e "\n${GREEN}🔹 Como usar:${NC}"
    echo "   1. Execute o script: deuzimar-downloader"
    echo "   2. Escolha a opção [1] no menu"
    echo "   3. Cole a URL do vídeo"
    echo "   4. Aguarde o download (o arquivo será salvo na pasta atual)"
    echo -e "\n${GREEN}🔹 Instalação (caso ainda não tenha instalado):${NC}"
    echo "   Se você ainda não tem o programa instalado, siga os passos abaixo:"
    echo "   -------------------------------------------------------------------"
    echo "   git clone https://github.com/seuusuario/deuzimar-downloader.git"
    echo "   cd deuzimar-downloader"
    echo "   chmod +x install.sh deuzimar-downloader.sh"
    echo "   ./install.sh"
    echo "   -------------------------------------------------------------------"
    echo "   O instalador vai pedir sua senha sudo para instalar yt-dlp, ffmpeg"
    echo "   e outras dependências. Depois, o comando 'deuzimar-downloader' fica"
    echo "   disponível no terminal."
    echo -e "\n${GREEN}🔹 Requisitos (instalados automaticamente pelo install.sh):${NC}"
    echo "   • yt-dlp      -> responsável pelo download"
    echo "   • ffmpeg      -> mescla vídeo e áudio"
    echo "   • curl, xclip -> utilitários extras"
    echo -e "\n${GREEN}🔹 Dicas:${NC}"
    echo "   • Você pode pausar com Ctrl+C e retomar depois (yt-dlp suporta)"
    echo "   • Para baixar apenas áudio, use a opção [2] (futura implementação)"
    echo "   • O arquivo será salvo com o título original do vídeo"
    echo -e "\n${GREEN}🔹 Licença:${NC}"
    echo "   MIT - Livre para uso pessoal e comercial, sem garantias."
    echo -e "\n${YELLOW}🔸 Exemplo de URL:${NC} https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    echo -e "\n${CYAN}Pressione ENTER para voltar ao menu...${NC}"
    read
}

download_video() {
    echo -e "\n${BLUE}📌 Cole a URL do vídeo:${NC}"
    read -p "> " url
    if [[ -z "$url" ]]; then
        echo -e "${RED}❌ Nenhuma URL foi fornecida.${NC}"
        sleep 1.5
        return
    fi
    
    echo -e "\n${GREEN}🔄 Verificando URL...${NC}"
    echo -e "${CYAN}📥 Comando: yt-dlp -f \"bestvideo*+bestaudio/best\" \"$url\"${NC}\n"
    
    yt-dlp -f "bestvideo*+bestaudio/best" "$url"
    
    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN}✅ Download concluído com sucesso! O arquivo está na pasta atual.${NC}"
    else
        echo -e "\n${RED}❌ Falha no download. Verifique a URL ou sua conexão.${NC}"
    fi
    
    echo -e "\n${CYAN}Pressione ENTER para continuar...${NC}"
    read
}

main_menu() {
    while true; do
        show_banner
        echo -e "${WHITE}┌─────────────────────────────────────────────────────────────┐${NC}"
        echo -e "${WHITE}│                    📀 MENU PRINCIPAL 📀                      │${NC}"
        echo -e "${WHITE}├─────────────────────────────────────────────────────────────┤${NC}"
        echo -e "${WHITE}│                                                             │${NC}"
        echo -e "${WHITE}│  ${GREEN}[1]${NC} 🎥 Baixar vídeo (melhor qualidade)                    ${WHITE}│${NC}"
        echo -e "${WHITE}│  ${GREEN}[2]${NC} 📖 Ver manual de uso (inclui instruções de instalação)${WHITE}│${NC}"
        echo -e "${WHITE}│  ${GREEN}[3]${NC} 🧹 Limpar tela                                        ${WHITE}│${NC}"
        echo -e "${WHITE}│  ${GREEN}[0]${NC} 🚪 Sair                                               ${WHITE}│${NC}"
        echo -e "${WHITE}│                                                             │${NC}"
        echo -e "${WHITE}└─────────────────────────────────────────────────────────────┘${NC}"
        echo -e "${YELLOW}💡 Dica: Você pode colar URLs usando Ctrl+Shift+V ou botão direito.${NC}"
        echo -ne "${BOLD}👉 Escolha uma opção: ${NC}"
        read opcao
        
        case $opcao in
            1) download_video ;;
            2) show_manual ;;
            3) clear ; show_banner ; echo -e "${GREEN}✅ Tela limpa!${NC}" ; sleep 1 ;;
            0) 
                echo -e "\n${GREEN}👋 Saindo do Deuzimar Downloader. Até logo!${NC}"
                exit 0
                ;;
            *) 
                echo -e "${RED}❌ Opção inválida! Pressione ENTER para tentar novamente.${NC}"
                read
                ;;
        esac
    done
}

if ! command -v yt-dlp &> /dev/null; then
    echo -e "${RED}⚠️  yt-dlp não está instalado!${NC}"
    echo -e "${YELLOW}Por favor, execute o instalador: ./install.sh${NC}"
    exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
    echo -e "${YELLOW}⚠️  ffmpeg não encontrado. A mesclagem de vídeo+áudio pode falhar.${NC}"
    echo -e "${YELLOW}Instale com: sudo apt install ffmpeg${NC}"
fi

main_menu
