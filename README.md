# 🌿 Juniper - Git Automation Toolkit

**Versão 2.0.0** - Arquitetura Modular

## 📂 Estrutura do Projeto

```
~/.juniper/                  # Pasta principal (precisa ficar na home do usuário)
  ├── juniper.sh           # Script principal (ponto de entrada)
  ├── commands/            # Comandos disponíveis (um por arquivo)
  │   ├── gitgrep.sh       # Comando de busca em commits
  │   ├── deployfeature.sh # Comando de deploy automatizado
  │   ├── help.sh          # Comando de ajuda
  │   ├── version.sh       # Comando de versão
  │   └── template.sh      # Template para criar novos comandos
  ├── core/                # Núcleo do sistema
  │   ├── dispatcher.sh    # Sistema de roteamento de comandos
  │   └── loader.sh        # Sistema de inicialização
  ├── utils/               # Utilitários compartilhados (futuro)
  └── README.md            # Documentação
```

## ⚙️ Instalação Global no Terminal

Para usar o comando `juniper` em qualquer lugar do terminal (Linux, WSL ou Git Bash), siga os passos abaixo:

### 1️⃣ Posicione o projeto na pasta home

Os scripts do Juniper esperam encontrar o projeto em `~/.juniper` (a home reconhecida pelo seu terminal). Depois de clonar o repositório em qualquer caminho, mova-o (ou clone diretamente) para lá:

```bash
# Se você já clonou em outro lugar, apenas mova a pasta:
mv /caminho/onde/voce/clonou/juniper-sh ~/.juniper

# Ou clone diretamente no destino correto:
git clone <url-do-repositorio> ~/.juniper
```

> ⚠️ No WSL e no Git Bash (Windows), `~` aponta para a home reconhecida pelo terminal (geralmente `C:\Users\<usuario>`), não necessariamente para onde você guarda seus projetos. Confirme o caminho com `echo ~` antes de mover a pasta.

### 2️⃣ Identifique seu Shell

Verifique qual shell você está usando:
```bash
echo $SHELL
```

Resultado comum:
- `/bin/bash` → Use `.bashrc`
- `/bin/zsh` → Use `.zshrc`
- `/usr/bin/zsh` → Use `.zshrc`

### 3️⃣ Adicione o Juniper ao seu Shell

Escolha o comando apropriado para seu shell:

#### Para Bash (Linux, WSL, Git Bash):
```bash
echo "" >> ~/.bashrc
echo "# Juniper - Git Automation Toolkit" >> ~/.bashrc
echo "[ -f ~/.juniper/juniper.sh ] && source ~/.juniper/juniper.sh" >> ~/.bashrc
```

#### Para Zsh (Oh My Zsh, etc):
```bash
echo "" >> ~/.zshrc
echo "# Juniper - Git Automation Toolkit" >> ~/.zshrc
echo "[ -f ~/.juniper/juniper.sh ] && source ~/.juniper/juniper.sh" >> ~/.zshrc
```

### 4️⃣ Recarregue o Shell

#### Para Bash:
```bash
source ~/.bashrc
```

#### Para Zsh:
```bash
source ~/.zshrc
```

Ou simplesmente feche e abra um novo terminal.

### 5️⃣ Teste a Instalação

```bash
juniper --version
```

Se tudo estiver correto, você verá:
```
🌿 Juniper v2.0.0
Arquitetura Modular
```

### 🐧 Compatibilidade

✅ **Linux** - Funciona nativamente em distribuições com Bash ou Zsh  
✅ **WSL** (Windows Subsystem for Linux) - Funciona perfeitamente  
✅ **Git Bash** - Funciona no Windows via Git Bash  
✅ **macOS** - Funciona com Bash ou Zsh (padrão no macOS moderno)

### 🔧 Solução de Problemas

**Problema:** Comando `juniper` não encontrado após instalação

**Soluções:**
1. Verifique se o projeto está na pasta correta:
   ```bash
   ls -la ~/.juniper/juniper.sh
   ```
   Se não existir, o projeto ainda não foi movido para `~/.juniper` (veja o passo 1️⃣ acima).

2. Verifique se foi adicionado ao arquivo correto:
   ```bash
   grep juniper ~/.bashrc  # ou ~/.zshrc
   ```

3. Certifique-se de que recarregou o shell:
   ```bash
   source ~/.bashrc  # ou source ~/.zshrc
   ```

4. Teste o script manualmente:
   ```bash
   source ~/.juniper/juniper.sh
   juniper --version
   ```

**Problema:** Erro de permissão

**Solução:**
```bash
chmod +x ~/.juniper/juniper.sh
```

### 🚀 Instalação Rápida (Uma Linha)

> Pressupõe que o projeto já foi movido para `~/.juniper` (passo 1️⃣).

#### Bash:
```bash
echo -e "\n# Juniper - Git Automation Toolkit\n[ -f ~/.juniper/juniper.sh ] && source ~/.juniper/juniper.sh" >> ~/.bashrc && source ~/.bashrc
```

#### Zsh:
```bash
echo -e "\n# Juniper - Git Automation Toolkit\n[ -f ~/.juniper/juniper.sh ] && source ~/.juniper/juniper.sh" >> ~/.zshrc && source ~/.zshrc
```

## 🎯 Arquitetura Modular

### Comandos (`commands/`)

Cada comando é um arquivo independente com duas funções obrigatórias:
- **`<comando>_run`** - Executa o comando
- **`<comando>_help`** - Retorna a ajuda do comando

**Exemplo de novo comando:**

```bash
#!/bin/zsh
# ~/.juniper/commands/meucomando.sh

meucomando_run() {
    echo "Executando meu comando com: $@"
}

meucomando_help() {
    cat << 'EOF'
  meucomando <arg>
      Descrição do comando
      Exemplo: juniper meucomando teste
EOF
}
```

### Dispatcher (`core/dispatcher.sh`)

- Sistema de roteamento automático
- Mapeia aliases para comandos
- Carrega comandos dinamicamente da pasta `commands/`

### Loader (`core/loader.sh`)

- Inicializa o sistema
- Carrega todos os módulos necessários

## 🚀 Como Adicionar um Novo Comando

### Método 1: Usando o Template (Recomendado)

1. **Copie o template:**
   ```bash
   cp ~/.juniper/commands/template.sh ~/.juniper/commands/meucomando.sh
   ```

2. **Edite o arquivo e substitua "seucomando" pelo nome do seu comando**

3. **Implemente a lógica:**
   ```bash
   meucomando_run() {
       # Sua implementação aqui
       echo "Olá, $1!"
   }
   ```

4. **Recarregue:**
   ```bash
   source ~/.juniper/juniper.sh
   ```

### Método 2: Do Zero

1. **Crie um arquivo em `~/.juniper/commands/`:**
   ```bash
   touch ~/.juniper/commands/meucomando.sh
   chmod +x ~/.juniper/commands/meucomando.sh
   ```

2. **Implemente as funções obrigatórias:**
   ```bash
   meucomando_run() {
       # Sua lógica aqui
   }
   
   meucomando_help() {
       # Documentação do comando
   }
   ```

3. **Adicione aliases (opcional) em `core/dispatcher.sh`:**
   ```bash
   JUNIPER_ALIASES=(
       # ... aliases existentes
       ["mc"]="meucomando"  # Adicione aqui
   )
   ```

4. **Recarregue o shell ou execute:**
   ```bash
   source ~/.juniper/juniper.sh
   ```

## 🎨 Comandos Disponíveis

### `gitgrep` / `grep`
Busca commits por termo
```bash
juniper gitgrep 4911
juniper grep "fix bug"
```

### `deployfeature` / `deploy`
Deploy automatizado para branches de feature
```bash
juniper deploy 4911 "Fix: corrige bug no login"
```

### `version` / `-v` / `--version`
Exibe informações sobre a versão do Juniper
```bash
juniper version
juniper --version
```

### `help` / `--help` / `-h`
Exibe ajuda dos comandos
```bash
juniper help
```

## 🔧 Vantagens da Arquitetura Modular

✅ **Separação de responsabilidades** - cada comando em seu próprio arquivo
✅ **Fácil manutenção** - modificações isoladas por comando
✅ **Extensível** - adicione novos comandos sem modificar o core
✅ **Autodocumentado** - cada comando tem sua própria função de ajuda
✅ **Descoberta automática** - comandos são carregados dinamicamente
✅ **Testável** - cada módulo pode ser testado independentemente

## 📝 Migrando de v1.0.0 para v2.0.0

A migração é transparente! Todos os comandos existentes continuam funcionando.
A única mudança é que o código agora está organizado modularmente.

---

**Criado por:** Petrus Rennan  
**Data:** 2026-08-27  
**Última atualização:** 2026-08-28
