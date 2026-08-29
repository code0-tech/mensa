#!/bin/sh
set -eu

KUBECONFIG="/etc/rancher/k3s/k3s.yaml"
export KUBECONFIG

FLUX_OPERATOR_VERSION="$1"

which helm >/dev/null 2>&1 || (curl -fsSL https://raw.githubusercontent.com/helm/helm/d2de64e64bc64cbef584a0ccb13eb8cb0c96bded/scripts/get-helm-4 | bash)

sudo -E helm upgrade --install flux-operator \
  oci://ghcr.io/controlplaneio-fluxcd/charts/flux-operator \
  --namespace flux-system \
  --create-namespace \
  --version "$FLUX_OPERATOR_VERSION" \
  --wait \
  --timeout 5m \
  --set "web.enabled=false"

sudo -E kubectl wait \
  --for=condition=Established \
  crd/fluxinstances.fluxcd.controlplane.io \
  --timeout=120s
