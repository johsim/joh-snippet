# Switches the current k8s context
kcs() {
  local q_par context

  [ ! -z "$@" ] && q_par="--query $@"
  context=$(kubectl config get-contexts --no-headers | sort | peco ${=q_par} | tr -s ' ' | cut -d' ' -f2)
  [ ! -z "$context" ] && kubectl config use-context $context
}

# Switches the current k8s namespace
kns() {
  local q_par ns

  [ ! -z "$@" ] && q_par="--query $@"
  ns=$(kubectl get namespaces --no-headers | sort | peco ${=q_par} | tr -s ' ' | cut -d' ' -f1)
  [ ! -z "$ns" ] && kubectl config set-context $(kubectl config current-context) --namespace="$ns"
}

krun() {
    kubectl run -it --rm \
            --restart=Never \
            --image=${KRUN_IMAGE:-busybox} \
            $(printf "random-%04x%04x" $RANDOM $RANDOM) \
            "$@"
}

choose_container() {
  local o p c

  o="custom-columns=NAME:.metadata.name,CONTAINERS:.spec.containers[*].name"

  read -r p c << EOF
$(kubectl get pods --no-headers -o="$o" | peco)
EOF

  if [[ "$c" =~ "," ]]; then
      c=$(echo "$c" | tr , "\n" | peco)
  fi

  echo "$p" "$c"
}

klogs() {
  read -r p c <<EOF
$(choose_container)
EOF
  if [[ -z "$c" ]]; then return 5; fi

  echo kubectl logs "$p" -c "$c" "$@"
       kubectl logs "$p" -c "$c" "$@"
}

kexec() {
  local cmd=${*:-"/bin/sh"}
  local p c

  read -r p c <<EOF
$(choose_container)
EOF
  if [[ -z "$c" ]]; then return 5; fi

  if which vared >/dev/null ; then
    vared -p "command: " cmd
    cmd=(${(ps: :)${cmd}})
  elif [[ $0 =~ "bash" ]]; then
    echo bash read
    read -er -p "command: " -i "$cmd" cmd
  else
    echo sh read
    read -r -p "command: " cmd
  fi

  echo kubectl exec -it "$p" -c "$c" -- $cmd
       kubectl exec -it "$p" -c "$c" -- $cmd
}
