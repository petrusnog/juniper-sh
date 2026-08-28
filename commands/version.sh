#!/bin/zsh
################################################################################
# VERSION Command
# Exibe a versão do Juniper
################################################################################

version_run() {
    cat << 'EOF'
🌿 JUNIPER - Git Automation Toolkit
   
   Versão: 2.0.0
   Arquitetura: Modular
   Autor: Petrus Rennan
   Data: 2026-08-27
   
   📂 Estrutura:
   ~/.juniper.sh              # Ponto de entrada
   ~/.juniper/
     ├── commands/            # Comandos modulares
     ├── core/                # Sistema core
     └── utils/               # Utilitários (futuro)

EOF
}

version_help() {
    cat << 'EOF'
  version, -v, --version
      Exibe a versão e informações do Juniper
      Exemplo: juniper version
EOF
}
