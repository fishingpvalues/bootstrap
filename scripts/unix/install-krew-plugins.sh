#!/usr/bin/env bash
set -e

KREW_PLUGINS=(ctx ns neat tail view-secret access-matrix get-all sniff tree who-can trace popeye konfig ktop resource-capacity deprecations)

if ! command -v kubectl-krew >/dev/null 2>&1; then
  echo "Installing Krew..."
  set -x
  cd "$(mktemp -d)"
  OS="$(uname | tr '[:upper:]' '[:lower:]')"
  ARCH="$(uname -m)"
  if [[ "$ARCH" == "x86_64" ]]; then ARCH="amd64"; fi
  if [[ "$ARCH" == "armv7l" ]]; then ARCH="arm"; fi
  KREW="krew-${OS}_${ARCH}"
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz"
  tar zxvf "${KREW}.tar.gz"
  ./${KREW} install krew
  export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
  set +x
fi

for plugin in "${KREW_PLUGINS[@]}"; do
  if ! kubectl krew list | grep -q "^$plugin$"; then
    kubectl krew install "$plugin"
  else
    echo "$plugin already installed."
  fi
fi 