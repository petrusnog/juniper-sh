#!/bin/zsh
################################################################################
# GITGREP Command
# Busca commits por padrão
################################################################################

gitgrep_run() {
    if [ -z "$1" ]; then
        echo "Uso: juniper gitgrep <termo_de_busca>"
        return 1
    fi
    git log --pretty=format:"(%ad) | HASH: %H | COMMIT: %s" \
        --date=format:'%d/%m/%Y %H:%M' --grep="$1"
}

gitgrep_help() {
    cat << 'EOF'
  gitgrep, grep <termo>
      Busca commits que contenham o termo especificado
      Exemplo: juniper gitgrep 4911
EOF
}
