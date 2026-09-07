#!/usr/bin/env bash
set -euo pipefail

curl -sL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.2-stable.tar.xz | tar -xJ
git config --global --add safe.directory "$(pwd)/flutter"
export PATH="$PATH:$(pwd)/flutter/bin"
flutter config --no-analytics
flutter build web --release
