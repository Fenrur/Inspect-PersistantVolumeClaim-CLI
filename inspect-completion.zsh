# Completion for inspect.sh
_inspect() {
    local state namespace

    _arguments \
        '1:Namespaces:->namespaces' \
        '2:PersistentVolumeClaims:->pvcs'
        
    case $state in
        namespaces)
            compadd $(kubectl get namespaces -o=jsonpath='{.items[*].metadata.name}')
            ;;
        pvcs)
            # Prendre le premier argument comme namespace
            namespace=${words[2]}
            compadd $(kubectl get pvc --namespace=$namespace -o=jsonpath='{.items[*].metadata.name}')
            ;;
    esac
}

# Association de la fonction de complétion à inspect.sh
compdef _inspect inspect.sh
