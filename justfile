nix_file := "loop-desktop.nix"

set quiet := true
set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

pull_appimage version:
  wget -O "loop-desktop-{{version}}-linux-x86_64.AppImage" \
    "https://artifacts.wilix.dev/repository/loop-files/loop-{{version}}/loop-desktop-{{version}}-linux-x86_64.AppImage"

  nix hash file "loop-desktop-{{version}}-linux-x86_64.AppImage"

get_latest_appimage_version:
  curl -sL "https://loop.ru/download/" \
    | rg -o 'loop-files/loop-([0-9.]+)' -r '$1' \
    | head -n1

pull_latest_appimage:
  just pull_appimage "$(just get_latest_appimage_version)"

update_application:
  #!/usr/bin/env bash
  set -euo pipefail

  OLD_VERSION="$(rg -m1 -o 'version = "[^"]+"' "{{nix_file}}" | sed 's/version = "\(.*\)"/\1/')"
  NEW_VERSION="$(just get_latest_appimage_version)"

  if [[ "$OLD_VERSION" == "$NEW_VERSION" ]]; then
    echo "Already up to date: $NEW_VERSION"
    exit 0
  fi

  HASH="$(just pull_appimage "$NEW_VERSION")"

  sed -i \
    -e 's/version = "[^"]*"/version = "'"$NEW_VERSION"'"/' \
    -e 's|hash = "[^"]*"|hash = "'"$HASH"'"|' \
    {{nix_file}}

  just cleanup
  echo "Updated: $OLD_VERSION -> $NEW_VERSION"

cleanup:
  rm -f -- *.AppImage
