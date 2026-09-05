#!/bin/zsh
# ~/.juniper/commands/install.sh

install_run() {
    echo "🌿 Iniciando a instalação de dependências da Juniper..."
    echo "-------------------------------------------------------"

    # 1. Instalação do jq
    echo "📦 Verificando jq..."
    if ! command -v jq &> /dev/null; then
        echo "Installing jq..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if command -v apt-get &> /dev/null; then
                sudo apt-get update && sudo apt-get install jq -y
            elif command -v pacman &> /dev/null; then
                sudo pacman -S jq --noconfirm
            else
                echo "❌ Gerenciador de pacotes não suportado. Instale o jq manualmente."
            fi
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install jq
        else
            echo "❌ Sistema operacional não suportado para instalação automática do jq."
        fi
    else
        echo "✅ jq já está instalado."
    fi

    # 2. Instalação do Ollama
    echo "\n🤖 Verificando Ollama..."
    if ! command -v ollama &> /dev/null; then
        echo "Installing Ollama..."
        curl -fsSL https://ollama.com/install.sh | sh
    else
        echo "✅ Ollama já está instalado."
    fi

    # 3. Download do Modelo Llama 3.1
    echo "\n🧠 Baixando modelo Llama 3.1 (8B)..."
    echo "Isso pode demorar dependendo da sua conexão."
    ollama pull llama3.1

    echo "\n-------------------------------------------------------"
    echo "✅ Tudo pronto! A Juniper agora tem cérebro e ferramentas."
    echo "Tente: juniper chat 'Olá Juniper!'"
}

install_help() {
    cat << 'EOF'
install / setup
    Automatiza a instalação de todas as dependências necessárias:
    - jq (processamento de JSON)
    - Ollama (motor de IA local)
    - Llama 3.1 (modelo de linguagem)
    Exemplo: juniper install
EOF
}
