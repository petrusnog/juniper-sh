#!/bin/zsh
################################################################################
# Command: Chat com a Juniper - Versão Failover Dinâmico
# Hierarquia: Groq API -> (Outra Nuvem) -> Ollama Local
################################################################################

# --- Funções de Inferência (Camadas) ---

infer_groq() {
    local sys_prompt="$1"
    local input="$2"
    curl -s https://api.groq.com/openai/v1/chat/completions \
        -H "Authorization: Bearer $GROQ_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"model\": \"llama-3.1-8b-instant\", \"messages\": [{\"role\": \"system\", \"content\": \"$sys_prompt\"}, {\"role\": \"user\", \"content\": \"$input\"}]}"
}

# Camada 2: Together AI (Fallback Nuvem) - Exemplo de API gratuita
infer_together() {
    curl -s https://api.together.xyz/v1/chat/completions \
        -H "Authorization: Bearer $TOGETHER_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"model\": \"meta-llama/Llama-3.1-8B-Instruct-Turbo\", \"messages\": [{\"role\": \"user\", \"content\": \"$1\"}]}"
}

# Chama o Ollama com stream ativado, imprimindo cada pedaço da resposta assim que chega.
# O texto completo é acumulado em JUNIPER_STREAM_REPLY (variável global) para uso pelo chamador.
infer_local_stream() {
    local sys_prompt="$1"
    local input="$2"

    local clean_prompt=$(echo -e "$sys_prompt\n\nUsuário: $input" | sed 's/"/\\"/g')

    local payload_file=$(mktemp)
    echo "{\"model\": \"llama3.1\", \"prompt\": \"$clean_prompt\", \"stream\": true}" > "$payload_file"

    JUNIPER_STREAM_REPLY=""
    local line chunk
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        chunk=$(echo "$line" | jq -r '.response // empty' 2>/dev/null)
        [ -n "$chunk" ] && printf "%s" "$chunk"
        JUNIPER_STREAM_REPLY+="$chunk"
    done < <(curl -s --no-buffer http://localhost:11434/api/generate -d @"$payload_file")

    rm -f "$payload_file"
}

# Executa uma função de inferência em background exibindo spinner até ela terminar
# Uso: response=$(_run_with_spinner infer_groq "$system_prompt" "$user_input")
_run_with_spinner() {
    local func="$1"
    shift
    local tmpfile=$(mktemp)

    ( "$func" "$@" > "$tmpfile" ) &
    local pid=$!

    local spinner='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    # Spinner vai para stderr para não contaminar a resposta capturada via $(...)
    while kill -0 "$pid" 2>/dev/null; do
        i=$(( (i + 1) % ${#spinner} ))
        printf "\r🌿 Estou pensando... %s" "${spinner:$i:1}" >&2
        sleep 0.1
    done
    wait "$pid"
    printf "\r\033[K" >&2

    cat "$tmpfile"
    rm -f "$tmpfile"
}

chat_run() {
    if [ -z "$1" ]; then
        echo "❌ Uso: juniper chat <mensagem>"
        return 1
    fi
    
    local user_input="$*"
    if ! command -v jq &> /dev/null; then
        echo "❌ Erro: 'jq' não está instalado."
        return 1
    fi

    local prompt_file="$HOME/.juniper/prompts/chat_system.txt"
    if [ ! -f "$prompt_file" ]; then
        echo "❌ Erro: prompt de sistema não encontrado em $prompt_file"
        return 1
    fi
    local system_prompt=$(<"$prompt_file")

    local response=""
    local reply=""
    local current_provider=""

    # TENTATIVA 1: GROQ
    current_provider="Groq (LPU)"
    response=$(_run_with_spinner infer_groq "$system_prompt" "$user_input")
    reply=$(echo "$response" | jq -r '.choices[0].message.content // empty')

    # TENTATIVA 2: Together AI (Se Groq falhar ou retornar erro 429)
    if [[ -z "$reply" || "$response" == *"429"* ]]; then
        echo "⚠️ Groq falhou ou indisponível. Acionando failover para Together AI..."
        current_provider="Together AI"
        response=$(_run_with_spinner infer_together "$system_prompt" "$user_input")
        reply=$(echo $response | jq -r '.choices[0].message.content // empty')
    fi

    # TENTATIVA 3: OLLAMA LOCAL (Failover, com streaming para feedback mais rápido)
    if [[ -z "$reply" || "$response" == *"429"* ]]; then
    echo "⚠️ Together AI falhou ou indisponível. Acionando failover para Ollama local..."
        _juniper_log_warn "chat: Groq falhou ou indisponível, acionando failover para Ollama local"
        current_provider="Ollama (Local)"
        printf "\n\033[1;34mJuniper (%s):\033[0m " "$current_provider"
        infer_local_stream "$system_prompt" "$user_input"
        reply="$JUNIPER_STREAM_REPLY"
        printf "\n"
    fi

    # Verificação Final
    if [ "$reply" = "null" ] || [ -z "$reply" ]; then
        _juniper_log_error "chat: Todas as camadas de inteligência falharam"
        echo -e "\n\033[1;31mErro:\033[0m Todas as camadas de inteligência falharam. Verifique os logs da API."
        return 1
    fi

    _juniper_log_info "chat: resposta obtida via $current_provider"

    # A resposta do Ollama já foi impressa em streaming acima; só exibe o rótulo para os demais provedores
    if [[ "$current_provider" != "Ollama (Local)" ]]; then
        echo -e "\n\033[1;34mJuniper ($current_provider):\033[0m $reply"
    fi
}

chat_help() {
    cat << 'EOF'
  chat <mensagem>
      Conversa direta com a Juniper com Failover Dinâmico.
      Prioridade: Groq Cloud -> Ollama Local.
      Exemplo: juniper chat "Como faço esse loop em ZSH?"
EOF
}
