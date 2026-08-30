#!/bin/sh
set -eu

INSTALL_K3S_VERSION="$1"
INSTALL_FLAGS="$2"

INSTALL_K3S_VERSION="$INSTALL_K3S_VERSION" sh /tmp/k3s-install-script.sh server $INSTALL_FLAGS

until sudo k3s kubectl get node 2>/dev/null | grep -q ' Ready'; do
  echo 'Waiting for node to be ready...'
  sleep 5
done
