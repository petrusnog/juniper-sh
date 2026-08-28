# Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

## [2.0.0] - 2026-08-28

### 🎉 Refatoração Completa - Arquitetura Modular

#### ✨ Adicionado
- Estrutura modular com separação por comandos
- Pasta `~/.juniper/commands/` para comandos individuais
- Pasta `~/.juniper/core/` para sistema central
- Pasta `~/.juniper/utils/` (reservada para utilitários futuros)
- Sistema de carregamento automático de comandos
- Sistema de aliases configurável
- Comando `version` para exibir informações do sistema
- Template (`template.sh`) para facilitar criação de novos comandos
- README.md completo com documentação
- Função `_juniper_load_commands()` para descoberta automática
- Dispatcher modular com roteamento inteligente

#### 🔄 Modificado
- Arquivo principal `.juniper.sh` agora é apenas ponto de entrada
- Comandos movidos para arquivos separados:
  - `gitgrep.sh` - busca em commits
  - `deployfeature.sh` - deploy automatizado
  - `help.sh` - sistema de ajuda dinâmico
- Sistema de ajuda agora descobre comandos automaticamente
- Versão atualizada para 2.0.0

#### 🏗️ Estrutura
```
ANTES (v1.0.0):
~/.juniper.sh (monolítico, ~200 linhas)

DEPOIS (v2.0.0):
~/.juniper.sh (28 linhas)
~/.juniper/
  ├── commands/       (comandos modulares)
  ├── core/           (sistema central)
  └── utils/          (futuro)
```

#### 🎯 Benefícios
- ✅ Código mais organizado e legível
- ✅ Fácil adicionar novos comandos (sem modificar core)
- ✅ Cada comando é independente e testável
- ✅ Autodescoberta de comandos
- ✅ Melhor manutenibilidade
- ✅ Escalável para crescimento futuro

#### 🔧 Compatibilidade
- ✅ 100% compatível com versão anterior
- ✅ Todos os comandos existentes funcionam sem alterações
- ✅ Sintaxe e aliases mantidos

---

## [1.0.0] - 2026-08-27

### Versão Inicial

#### ✨ Adicionado
- Comando `gitgrep` - busca commits por termo
- Comando `deployfeature` - deploy automatizado para branches
- Sistema de aliases (`grep`, `deploy`)
- Sistema de ajuda
- Saudação personalizada
- Banner ASCII art
- Suporte para branches feature/{id}-develop e feature/{id}-stage
- Cherry-pick automático entre branches
- Gestão de erros no deploy

#### 🎨 Features
- Busca inteligente em histórico git
- Deploy automatizado multi-branch
- Criação automática de branches
- Push automático
- Tratamento de erros

---

**Legenda:**
- ✨ Adicionado - Novas features
- 🔄 Modificado - Mudanças em features existentes
- 🐛 Corrigido - Correção de bugs
- 🗑️ Removido - Features removidas
- 🔧 Manutenção - Ajustes técnicos
- 📚 Documentação - Melhorias na documentação
