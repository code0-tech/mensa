#!/bin/sh
set -eu

KUBECONFIG="/etc/rancher/k3s/k3s.yaml"
export KUBECONFIG

INSTANCE_MANIFEST="$1"
NOTIFICATIONS_MANIFEST="$2"

sudo -E kubectl apply -f "$INSTANCE_MANIFEST"

sudo -E kubectl wait \
  --for=condition=Ready \
  fluxinstance/flux \
  -n flux-system \
  --timeout=300s

sudo -E kubectl apply -f "$NOTIFICATIONS_MANIFEST"

rm -f "$INSTANCE_MANIFEST" "$NOTIFICATIONS_MANIFEST"
