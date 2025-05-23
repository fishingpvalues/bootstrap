#!/usr/bin/env bash
set -e

TOOLS=(
  eza bat fd ripgrep sd xh gitui rga broot dua-cli ncdu just atuin bandwhich hyperfine miniserve dog choose-gui zoxide yazi lazygit onefetch
)

# Add SOTA Kubernetes tools to the install list
TOOLS+=(
  k9s popeye kubectx kubens stern kubetail kube-ps1 helm helmfile kubeseal kubeval kube-score kube-linter krew kustomize kind minikube skaffold tilt kubefwd kubecolor kubelogin kubespy kubescape kubectl-tree kubectl-neat kubectl-view-secret kubectl-who-can kubectl-resource-capacity kubectl-access-matrix kubectl-get-all kubectl-trace kubectl-sniff kubectl-konfig kubectl-ktop kubectl-deprecations
)

# Add SOTA Docker tools to the install list
TOOLS+=(
  docker docker-compose docker-buildx docker-slim dive ctop lazydocker dockly hadolint yamllint
)

if command -v brew >/dev/null 2>&1; then
  echo "Installing SOTA CLI tools with Homebrew..."
  for tool in "${TOOLS[@]}"; do
    if ! brew list --formula | grep -q "^$tool$"; then
      brew install "$tool"
    else
      echo "$tool already installed."
    fi
  done
else
  echo "Homebrew not found. Attempting apt/yum install (best effort)..."
  if command -v apt >/dev/null 2>&1; then
    sudo apt update
    sudo apt install -y eza bat fd-find ripgrep sd xh gitui broot dua-cli ncdu just atuin bandwhich hyperfine miniserve dog zoxide lazygit
  elif command -v yum >/dev/null 2>&1; then
    sudo yum install -y eza bat fd-find ripgrep sd xh gitui broot dua-cli ncdu just atuin bandwhich hyperfine miniserve dog zoxide lazygit
  else
    echo "No supported package manager found. Please install tools manually."
  fi
fi 