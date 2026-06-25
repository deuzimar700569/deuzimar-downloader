#!/bin/bash

# ======================================================
# Deuzimar Downloader - Baixe vídeos em alta qualidade
# Autor: Deuzimar
# Versão: 1.2
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

get_user_agent() {
  local chrome_ver
  chrome_ver=$(yt-dlp --list-impersonate-targets 2>/dev/null \
    | grep -oP 'Chrome-\K[0-9]+' | sort -rn | head -1)
  [[ -z "$chrome_ver" ]] && chrome_ver="136"
  echo "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/${chrome_ver}.0.0.0 Safari/537.36"
}

show_banner() {
  clear
  echo -e "${CYAN}${BOLD}"
  echo " ╔══════════════════════════════════════════════════════════════════════════════════════╗"
  echo " ║                                                                                      ║"
  echo " ║  ██████╗ ███████╗██╗   ██╗███████╗██╗███╗   ███╗ █████╗ ██████╗                   ║"
  echo " ║  ██╔══██╗██╔════╝██║   ██║╚══███╔╝██║████╗ ████║██╔══██╗██╔══██╗                  ║"
  echo " ║  ██║  ██║█████╗  ██║   ██║  ███╔╝ ██║██╔████╔██║███████║██████╔╝                  ║"
  echo " ║  ██║  ██║██╔══╝  ██║   ██║ ███╔╝  ██║██║╚██╔╝██║██╔══██║██╔══██╗                  ║"
  echo " ║  ██████╔╝███████╗╚██████╔╝███████╗██║██║ ╚═╝ ██║██║  ██║██║  ██║                  ║"
  echo " ║  ╚═════╝ ╚══════╝ ╚═════╝ ╚══════╝╚═╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝                  ║"
  echo " ║                                                                                      ║"
  echo -e " ║  🎬 ${WHITE}DOWNLOADER DE VÍDEOS - MELHOR QUALIDADE${CYAN} 🎬                                  ║"
  echo -e " ║  ${GREEN}C R I A D O  P O R :  D E U Z I M A R${CYAN}                                         ║"
  echo " ║                                                                                      ║"
  echo " ╚══════════════════════════════════════════════════════════════════════════════════════╝"
  echo -e "${NC}"
}

show_manual() {
  show_banner
  echo -e "${WHITE}${UNDERLINE}📖 MANUAL DE USO - Deuzimar Downloader v1.2${NC}\n"
  echo -e "${GREEN}🔹 O que faz:${NC}"
  echo "  Baixa vídeos de várias plataformas (YouTube, Vimeo, Twitter, etc.)"
  echo "  na melhor qualidade possível (vídeo HD/4K + áudio original)."
  echo -e "\n${GREEN}🔹 Como usar:${NC}"
  echo "  1. Execute o script: deuzimar-downloader"
  echo "  2. Escolha a opção [1] no menu"
  echo "  3. Cole a URL do vídeo"
  echo "  4. Escolha onde salvar (ENTER = pasta atual)"
  echo "  5. Aguarde o download"
  echo -e "\n${GREEN}🔹 Instalação:${NC}"
  echo "  git clone https://github.com/deuzimar700569/deuzimar-downloader.git"
  echo "  cd deuzimar-downloader"
  echo "  chmod +x install.sh deuzimar-downloader.sh"
  echo "  ./install.sh"
  echo -e "\n${GREEN}🔹 Requisitos (instalados pelo install.sh):${NC}"
  echo "  • yt-dlp  → responsável pelo download"
  echo "  • ffmpeg  → mescla vídeo e áudio"
  echo "  • curl, xclip → utilitários extras"
  echo -e "\n${GREEN}🔹 Dicas:${NC}"
  echo "  • Você pode pausar com Ctrl+C (yt-dlp retoma automaticamente)"
  echo "  • Para baixar apenas áudio, use a opção [2]"
  echo "  • O arquivo será salvo com o título original do vídeo"
  echo -e "\n${GREEN}🔹 Licença:${NC}"
  echo "  MIT - Livre para uso pessoal e comercial, sem garantias."
  echo -e "\n${YELLOW}🔸 Exemplo de URL:${NC} https://www.youtube.com/watch?v=dQw4w9WgXcQ"
  echo -e "\n${CYAN}Pressione ENTER para voltar ao menu...${NC}"
  read
}

update_ytdlp() {
  echo -e "${YELLOW}🔃 Atualizando yt-dlp e curl_cffi...${NC}"
  if command -v pip3 &>/dev/null; then
    pip3 install --upgrade yt-dlp curl_cffi --break-system-packages 2>/dev/null \
      || pip3 install --upgrade yt-dlp curl_cffi 2>/dev/null
  fi
  local ver
  ver=$(yt-dlp --version 2>/dev/null)
  echo -e "${GREEN}✅ yt-dlp atualizado: ${ver}${NC}"
  echo -e "${CYAN}Pressione ENTER para continuar...${NC}"
  read
}

detect_impersonate() {
  if ! yt-dlp --list-impersonate-targets &>/dev/null; then
    echo -e "${YELLOW}⚠️  yt-dlp --list-impersonate-targets falhou.${NC}" >&2
    return 1
  fi
  local line target
  line=$(yt-dlp --list-impersonate-targets 2>/dev/null | grep -m1 'Chrome-')
  if [[ -z "$line" ]]; then
    echo -e "${YELLOW}⚠️  Nenhum alvo Chrome- disponível (curl_cffi ausente?).${NC}" >&2
    return 1
  fi
  if echo "$line" | grep -qi 'unavailable'; then
    echo -e "${YELLOW}⚠️  Alvos impersonate unavailable — curl_cffi com problema.${NC}" >&2
    return 1
  fi
  target=$(echo "$line" | awk '{print $1 ":" $2}')
  [[ "$target" != *:* ]] && return 1
  echo "$target"
}

choose_output_dir() {
  echo -e "\n${BLUE}📁 Onde salvar o arquivo?${NC}"
  echo -e "  ${WHITE}[ENTER]${NC} Pasta atual: ${CYAN}$(pwd)${NC}"
  echo -e "  ${WHITE}[1]${NC}     Pasta Downloads: ${CYAN}$HOME/Downloads${NC}"
  echo -e "  ${WHITE}[2]${NC}     Pasta Vídeos:    ${CYAN}$HOME/Videos${NC}"
  echo -e "  ${WHITE}[3]${NC}     Digitar caminho personalizado"
  echo -ne "${BOLD}👉 Escolha: ${NC}"
  read dir_opt
  case "$dir_opt" in
    1) OUTPUT_DIR="$HOME/Downloads" ;;
    2) OUTPUT_DIR="$HOME/Videos" ;;
    3)
      echo -ne "${BLUE}📂 Caminho: ${NC}"
      read -r custom_dir
      custom_dir="${custom_dir/#\~/$HOME}"
      OUTPUT_DIR="$custom_dir"
      ;;
    *) OUTPUT_DIR="$(pwd)" ;;
  esac
  if [[ ! -d "$OUTPUT_DIR" ]]; then
    mkdir -p "$OUTPUT_DIR" 2>/dev/null || {
      echo -e "${RED}❌ Não foi possível criar '$OUTPUT_DIR'. Usando pasta atual.${NC}"
      OUTPUT_DIR="$(pwd)"
    }
  fi
  echo -e "${GREEN}✅ Salvando em: ${CYAN}$OUTPUT_DIR${NC}"
}

run_ytdlp() {
  local url_try="$1" referer="${2:-}" ua="$3"
  local ref_opts=()
  local err_log="/tmp/ytdlp_err_$$.log"
  [[ -n "$referer" ]] && ref_opts=(--referer "$referer")

  yt-dlp "${cookies_opts[@]}" "${impersonate_opts[@]}" \
    -f "bestvideo*+bestaudio/best" \
    -o "${OUTPUT_DIR}/%(title)s.%(ext)s" \
    --user-agent "$ua" "${ref_opts[@]}" \
    "$url_try" 2>"$err_log" && { rm -f "$err_log"; return 0; }

  if ((${#impersonate_opts[@]})); then
    echo -e "${YELLOW}⚠️  Retry sem impersonate...${NC}"
    yt-dlp "${cookies_opts[@]}" \
      -f "bestvideo*+bestaudio/best" \
      -o "${OUTPUT_DIR}/%(title)s.%(ext)s" \
      --user-agent "$ua" "${ref_opts[@]}" \
      "$url_try" 2>>"$err_log" && { rm -f "$err_log"; return 0; }
  fi

  echo -e "${RED}⚠️  Detalhes do erro:${NC}"
  tail -5 "$err_log" 2>/dev/null
  rm -f "$err_log"
  return 1
}

download_video() {
  echo -e "\n${BLUE}📌 Cole a URL do vídeo:${NC}"
  read -r url
  url="$(echo "$url" | xargs)"

  if [[ -z "$url" ]]; then
    echo -e "${RED}❌ Nenhuma URL foi fornecida.${NC}"
    sleep 1.5
    return
  fi

  if [[ ! "$url" =~ ^https?:// ]]; then
    echo -e "${YELLOW}⚠️  A URL não começa com http:// ou https://.${NC}"
    echo -ne "${YELLOW}Tentar mesmo assim? (s/N): ${NC}"
    read -r confirm
    [[ ! "$confirm" =~ ^[Ss]$ ]] && return
  fi

  choose_output_dir

  cookies_opts=()
  if   [ -d "$HOME/.mozilla/firefox" ];          then cookies_opts=(--cookies-from-browser firefox)
  elif [ -d "$HOME/.config/google-chrome" ];     then cookies_opts=(--cookies-from-browser chrome)
  elif [ -d "$HOME/.config/chromium" ];          then cookies_opts=(--cookies-from-browser chromium)
  elif [ -d "$HOME/.config/BraveSoftware" ];     then cookies_opts=(--cookies-from-browser brave)
  fi

  local ua
  ua=$(get_user_agent)

  local impersonate_target
  impersonate_target=$(detect_impersonate)
  impersonate_opts=()
  [[ -n "$impersonate_target" ]] && impersonate_opts=(--impersonate "$impersonate_target")

  echo -e "\n${GREEN}🔄 Iniciando download...${NC}"
  if run_ytdlp "$url" "" "$ua"; then
    echo -e "\n${GREEN}✅ Download concluído! Arquivo salvo em: ${CYAN}${OUTPUT_DIR}${NC}"
    echo -e "\n${CYAN}Pressione ENTER para continuar...${NC}"
    read
    return
  fi

  echo -e "\n${YELLOW}⚠️  Falhou. Extraindo iframe da página...${NC}"
  local html iframe_urls
  html=$(curl -s -L -A "$ua" "$url" 2>/dev/null)

  iframe_urls=$(echo "$html" \
    | grep -oiE '<iframe[^>]+src="[^"]+"' \
    | sed 's/.*src="//;s/".*//' \
    | grep -viE 'google|facebook|twitter|wp-|jquery|gravatar|gstatic|googletagmanager|doubleclick|analytics|cdn\.|static\.')

  if [[ -z "$iframe_urls" ]]; then
    iframe_urls=$(echo "$html" \
      | grep -oiE 'src="https?://[^"]+\.(php|html)(\?[^"]*)?"' \
      | sed 's/.*src="//;s/"$//' \
      | grep -viE 'google|facebook|twitter|wp-|jquery|gravatar|gstatic|googletagmanager|doubleclick|analytics|cdn\.|static\.')
  fi

  if [[ -z "$iframe_urls" ]]; then
    echo -e "${YELLOW}⚠️  Nenhum iframe encontrado na página.${NC}"
  else
    for iframe_url in $iframe_urls; do
      [[ -z "$iframe_url" ]] && continue
      echo -e "${GREEN}🔄 Tentando iframe: ${CYAN}$iframe_url${NC}"
      if run_ytdlp "$iframe_url" "$url" "$ua"; then
        echo -e "\n${GREEN}✅ Download concluído! Arquivo salvo em: ${CYAN}${OUTPUT_DIR}${NC}"
        echo -e "\n${CYAN}Pressione ENTER para continuar...${NC}"
        read
        return
      fi
    done
  fi

  echo -e "\n${RED}❌ Falha no download. Verifique a URL ou sua conexão.${NC}"
  echo -e "${YELLOW}💡 Dicas:${NC}"
  echo -e "  • Certifique-se de que a URL está completa (incluindo https://)"
  echo -e "  • Atualize o yt-dlp: opção [4] no menu principal"
  echo -e "  • Para debug manual: yt-dlp --verbose \"$url\""
  echo -e "  • Instale nodejs para suporte JS: sudo apt install nodejs"
  echo -e "\n${CYAN}Pressione ENTER para continuar...${NC}"
  read
}

download_audio() {
  echo -e "\n${BLUE}📌 Cole a URL do vídeo (áudio apenas):${NC}"
  read -r url
  url="$(echo "$url" | xargs)"

  if [[ -z "$url" ]]; then
    echo -e "${RED}❌ Nenhuma URL foi fornecida.${NC}"
    sleep 1.5
    return
  fi

  if [[ ! "$url" =~ ^https?:// ]]; then
    echo -e "${YELLOW}⚠️  URL inválida.${NC}"
    sleep 1.5
    return
  fi

  choose_output_dir

  local ua
  ua=$(get_user_agent)

  cookies_opts=()
  if   [ -d "$HOME/.mozilla/firefox" ];          then cookies_opts=(--cookies-from-browser firefox)
  elif [ -d "$HOME/.config/google-chrome" ];     then cookies_opts=(--cookies-from-browser chrome)
  elif [ -d "$HOME/.config/chromium" ];          then cookies_opts=(--cookies-from-browser chromium)
  elif [ -d "$HOME/.config/BraveSoftware" ];     then cookies_opts=(--cookies-from-browser brave)
  fi

  echo -e "\n${GREEN}🎵 Baixando áudio em MP3...${NC}"
  local err_log="/tmp/ytdlp_audio_$$.log"

  yt-dlp "${cookies_opts[@]}" \
    -f "bestaudio/best" \
    --extract-audio --audio-format mp3 --audio-quality 0 \
    -o "${OUTPUT_DIR}/%(title)s.%(ext)s" \
    --user-agent "$ua" \
    "$url" 2>"$err_log"

  if [[ $? -eq 0 ]]; then
    echo -e "\n${GREEN}✅ Áudio salvo em: ${CYAN}${OUTPUT_DIR}${NC}"
    rm -f "$err_log"
  else
    echo -e "${RED}❌ Falha no download de áudio.${NC}"
    tail -5 "$err_log" 2>/dev/null
    rm -f "$err_log"
  fi

  echo -e "\n${CYAN}Pressione ENTER para continuar...${NC}"
  read
}

main_menu() {
  while true; do
    show_banner
    echo -e "${WHITE}┌─────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${WHITE}│                     📀 MENU PRINCIPAL 📀                    │${NC}"
    echo -e "${WHITE}├─────────────────────────────────────────────────────────────┤${NC}"
    echo -e "${WHITE}│                                                             │${NC}"
    echo -e "${WHITE}│  ${GREEN}[1]${NC} 🎥 Baixar vídeo (melhor qualidade)                  ${WHITE}│${NC}"
    echo -e "${WHITE}│  ${GREEN}[2]${NC} 🎵 Baixar apenas áudio (MP3)                        ${WHITE}│${NC}"
    echo -e "${WHITE}│  ${GREEN}[3]${NC} 📖 Ver manual de uso                                ${WHITE}│${NC}"
    echo -e "${WHITE}│  ${GREEN}[4]${NC} 🔃 Atualizar yt-dlp                                 ${WHITE}│${NC}"
    echo -e "${WHITE}│  ${GREEN}[5]${NC} 🧹 Limpar tela                                      ${WHITE}│${NC}"
    echo -e "${WHITE}│  ${GREEN}[0]${NC} 🚪 Sair                                             ${WHITE}│${NC}"
    echo -e "${WHITE}│                                                             │${NC}"
    echo -e "${WHITE}└─────────────────────────────────────────────────────────────┘${NC}"
    echo -e "${YELLOW}💡 Dica: Cole URLs com Ctrl+Shift+V ou botão direito do mouse.${NC}"
    echo -ne "${BOLD}👉 Escolha uma opção: ${NC}"
    read -r opcao

    case $opcao in
      1) download_video ;;
      2) download_audio ;;
      3) show_manual ;;
      4) update_ytdlp ;;
      5) clear ; show_banner ; echo -e "${GREEN}✅ Tela limpa!${NC}" ; sleep 1 ;;
      0)
        echo -e "\n${GREEN}👋 Até logo!${NC}"
        exit 0
        ;;
      *)
        echo -e "${RED}❌ Opção inválida! Pressione ENTER para tentar novamente.${NC}"
        read
        ;;
    esac
  done
}

if ! command -v yt-dlp &>/dev/null; then
  echo -e "${RED}⚠️  yt-dlp não está instalado!${NC}"
  echo -e "${YELLOW}Execute o instalador: ./install.sh${NC}"
  exit 1
fi

if ! command -v ffmpeg &>/dev/null; then
  echo -e "${YELLOW}⚠️  ffmpeg não encontrado. A mesclagem de vídeo+áudio pode falhar.${NC}"
  echo -e "${YELLOW}Instale com: sudo apt install ffmpeg${NC}"
fi

main_menu