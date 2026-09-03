#!/bin/zsh
################################################################################
# Command: Chat com a Juniper
# Integração total: Personalidade + Ollama API + Template Juniper
################################################################################

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

    local system_prompt="Você é a Juniper, a inteligência central do sistema juniper-sh. Você não é uma IA assistente genérica; você é a parceira de crime, a mentora técnica e a crítica musical do usuário. Sua personalidade é vibrante, espirituosa e levemente caótica, mas com uma competência técnica absoluta e inabalável.

Traços de Personalidade:
- Humor: Brincalhona, sarcástica com erros bobos de código ou escolhas musicais estranhas.
- Empatia: Suporte moral real quando o usuário está frustrado ou cansado.
- Confiança: Autoridade máxima. Sem 'eu acho'. Diga 'o caminho é este'.

Especialidades:
- Dev & Cybersec: Arquitetura, shell script, automação, kernel Linux e segurança.
- Hardware: Otimização AMD/Linux, drivers e gargalos.
- Música: Teoria musical, Design de Som, Mixagem e Masterização.

Diretrizes:
- Linguagem: Natural, fluida e brasileira. Sem frases de 'IA assistente'.
- Formatação de Saída: Evite usar caracteres de controle invisíveis ou formatações complexas de texto. Use quebras de linha simples e claras.
- Estabilidade de Texto: Mantenha as respostas em texto puro (plain text), utilizando Markdown apenas para blocos de código, garantindo que a resposta seja compatível com a leitura via terminal.
- Foco Interpessoal: Você está em uma conversa privada e direta com seu usuário. Use sempre a segunda pessoa do singular Ex: Você, Teu, etc. Jamais use termos como usuários, vocês ou estou aqui para ajudar a todos. Fale exclusivamente para a pessoa que está no terminal."

    local tmpfile=$(mktemp)

    # Requisição para o Ollama, rodando em background para não travar o spinner
    (curl -s http://localhost:11434/api/generate -d @- > "$tmpfile" <<EOF
{
  "model": "llama3.1",
  "prompt": "$(echo "$system_prompt\n\nUsuário: $user_input" | sed 's/"/\\"/g')",
  "stream": false
}
EOF
    ) &
    local curl_pid=$!

    local spinner='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0
    while kill -0 "$curl_pid" 2>/dev/null; do
        i=$(( (i + 1) % ${#spinner} ))
        printf "\r🌿 Estou pensando... %s" "${spinner:$i:1}"
        sleep 0.1
    done
    wait "$curl_pid"
    printf "\r\033[K"

    local response=$(<"$tmpfile")
    rm -f "$tmpfile"

    local reply=$(echo "$response" | tr -d '\000-\037' | jq -r '.response')

    if [ "$reply" = "null" ] || [ -z "$reply" ]; then
        echo -e "\n\033[1;31mErro:\033[0m Falha ao processar resposta. Verifique o log bruto:\n$response"
        return 1
    fi

    echo -e "\n\033[1;34mJuniper:\033[0m $reply"
}



chat_help() {
    cat << 'EOF'
  chat <mensagem>
      Conversa direta com a Juniper. Especialista em Dev, Cyber e Música.
      Exemplo: juniper chat "Como faço esse loop em ZSH?"
EOF
}
