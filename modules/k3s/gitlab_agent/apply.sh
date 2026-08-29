#!/bin/sh
set -eu

KUBECONFIG="/etc/rancher/k3s/k3s.yaml"
export KUBECONFIG

MANIFEST="$1"

sudo -E kubectl apply -f "$MANIFEST"

sudo -E kubectl wait \
  --for=condition=Ready \
  helmrelease/gitlab-agent \
  -n flux-system \
  --timeout=300s

rm -f "$MANIFEST"
