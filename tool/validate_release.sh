#!/usr/bin/env bash
# Build on a local filesystem: external Mac volumes may create ._* resources.
set -Eeuo pipefail
trap 'printf "Validation failed at line %s. Temporary source retained: %s\n" "$LINENO" "${release_workdir:-not created}" >&2' ERR

for dependency in flutter rsync mktemp; do
  if ! command -v "$dependency" >/dev/null 2>&1; then
    printf 'Missing dependency: %s\n' "$dependency" >&2
    exit 1
  fi
done

release_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
release_workdir="$(mktemp -d /private/tmp/night-jump-release.XXXXXX)"
printf 'Validation source: %s\n' "$release_workdir"
rsync -a --exclude='.git' --exclude='.agents' --exclude='build' \
  --exclude='.dart_tool' --exclude='Pods' --exclude='.symlinks' \
  --exclude='._*' --exclude='*.log' "$release_root/" "$release_workdir/"

cd -- "$release_workdir"
# Homebrew's cmdline-tools symlink makes apkanalyzer infer Homebrew as SDK.
# Supply a locator beneath the real SDK without changing the installed tools.
release_sdk="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
if [[ -L "$release_sdk/cmdline-tools/latest" && -d "$release_sdk/build-tools" ]]; then
  if [[ ! "$release_sdk" =~ ^/[a-zA-Z0-9_./-]+$ ]]; then
    printf 'Linked SDK path contains unsupported characters; install cmdline-tools directly inside the SDK.\n' >&2
    exit 1
  fi
  export APKANALYZER_OPTS="${APKANALYZER_OPTS:-} -Dcom.android.sdklib.toolsdir=$release_sdk/cmdline-tools/night-jump-sdk-root"
fi
flutter pub get
flutter analyze
flutter test --coverage
flutter build appbundle --release
printf 'Android bundle: %s/build/app/outputs/bundle/release/app-release.aab\n' "$release_workdir"
# The copy is deliberately retained for artifact review and reproducibility.
