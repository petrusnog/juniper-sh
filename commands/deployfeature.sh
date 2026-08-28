#!/bin/zsh
################################################################################
# DEPLOYFEATURE Command
# Deploy automatizado para branches de feature
################################################################################

# Função auxiliar: Garante que a branch existe
_ensure_branch_exists() {
    local target_branch="$1"
    local base_branch="$2"
    
    # Se a branch já existe remotamente, apenas faz checkout
    if git show-ref --verify --quiet "refs/remotes/origin/${target_branch}"; then
        echo "🔀 Branch ${target_branch} encontrada, aplicando..."
        git checkout "$target_branch" 2>/dev/null
        return 0
    fi
    
    # Se a base existe, cria a nova branch
    if git show-ref --verify --quiet "refs/remotes/origin/${base_branch}" || \
       git show-ref --verify --quiet "refs/heads/${base_branch}"; then
        echo "✨ Criando branch ${target_branch} a partir de ${base_branch}..."
        git checkout "$base_branch" && \
        git pull origin "$base_branch" 2>/dev/null && \
        git checkout -b "$target_branch" && \
        git push -u origin "$target_branch"
        return $?
    fi
    
    echo "⚠️  Branch ${base_branch} não encontrada, pulando ${target_branch}..."
    return 1
}

# Função auxiliar: Aplica commit em uma branch
_apply_commit_to_branch() {
    local branch_name="$1"
    local commit_hash="$2"
    
    if ! git rev-parse --verify "$branch_name" >/dev/null 2>&1; then
        return 1
    fi
    
    git checkout "$branch_name" || return 1
    
    if ! git cherry-pick "$commit_hash" 2>/dev/null; then
        echo "❌ Erro no cherry-pick para ${branch_name}"
        git cherry-pick --abort 2>/dev/null
        return 1
    fi
    
    echo "⬆️  Push para ${branch_name}..."
    git push origin "$branch_name" || return 1
    
    return 0
}

deployfeature_run() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "Uso: juniper deployfeature <id-feature> <mensagem-do-commit>"
        echo "Exemplo: juniper deploy 4911 'Fix: corrige bug no login'"
        return 1
    fi
    
    local feature_id="$1"
    local commit_msg="$2"
    local current_branch=$(git branch --show-current)
    local has_errors=false
    
    # Cria o commit inicial
    echo "📝 Adicionando arquivos..."
    git add .
    
    echo "💾 Fazendo commit: $commit_msg"
    if ! git commit -m "$commit_msg"; then
        echo "❌ Erro ao fazer commit"
        return 1
    fi
    
    local commit_hash=$(git rev-parse HEAD)
    echo "✅ Commit criado: $commit_hash"
    
    # Atualiza referências remotas
    echo "\n🔍 Buscando branches remotas..."
    git fetch origin
    
    # Processa branch develop
    local develop_branch="feature/${feature_id}-develop"
    if _ensure_branch_exists "$develop_branch" "develop"; then
        _apply_commit_to_branch "$develop_branch" "$commit_hash" || has_errors=true
    else
        has_errors=true
    fi
    
    # Processa branch stage
    local stage_branch="feature/${feature_id}-stage"
    if _ensure_branch_exists "$stage_branch" "stage"; then
        _apply_commit_to_branch "$stage_branch" "$commit_hash" || has_errors=true
    else
        has_errors=true
    fi
    
    # Retorna à branch original
    echo "\n↩️  Voltando para branch original: $current_branch"
    git checkout "$current_branch"
    
    # Mensagem final
    if [ "$has_errors" = true ]; then
        echo "⚠️  Deploy concluído com alguns erros"
    else
        echo "✨ Deploy concluído com sucesso!"
    fi
    echo "   Commit: $commit_hash"
    echo "   Feature: $feature_id"
}

deployfeature_help() {
    cat << 'EOF'
  deployfeature, deploy <id-feature> <mensagem>
      Cria commit e aplica automaticamente nas branches develop e stage
      Exemplo: juniper deploy 4911 "Fix: corrige bug no login"
EOF
}
