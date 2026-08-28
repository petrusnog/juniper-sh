#!/bin/zsh
################################################################################
# CORE LOADER
# Sistema de inicialização do Juniper
################################################################################

# Carrega módulos core
_juniper_init() {
    local juniper_home="$HOME/.juniper"
    
    # Carrega dispatcher
    [ -f "$juniper_home/core/dispatcher.sh" ] && source "$juniper_home/core/dispatcher.sh"
    
    # Carrega todos os comandos
    _juniper_load_commands
}

# Inicializa automaticamente ao carregar
_juniper_init
