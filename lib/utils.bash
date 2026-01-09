#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-or-later
set -euo pipefail

TOOL_NAME="orchid"
TOOL_REPO="orchidhq/Orchid"
BINARY_NAME="orchid"

fail() { echo -e "\e[31mFail:\e[m $*" >&2; exit 1; }

list_all_versions() {
  local curl_opts=(-sL)
  [[ -n "${GITHUB_TOKEN:-}" ]] && curl_opts+=(-H "Authorization: token $GITHUB_TOKEN")
  curl "${curl_opts[@]}" "https://api.github.com/repos/$TOOL_REPO/releases" 2>/dev/null | \
    grep -o '"tag_name": "[^"]*"' | sed 's/"tag_name": "//' | sed 's/"$//' | sort -V
}

download_release() {
  local version="$1" download_path="$2"
  local url="https://github.com/$TOOL_REPO/releases/download/${version}/OrchidCli-${version}.jar"

  echo "Downloading Orchid $version..."
  mkdir -p "$download_path"
  curl -fsSL "$url" -o "$download_path/orchid.jar" || fail "Download failed"
}

install_version() {
  local install_type="$1" version="$2" install_path="$3"

  mkdir -p "$install_path/bin" "$install_path/lib"
  cp "$ASDF_DOWNLOAD_PATH/orchid.jar" "$install_path/lib/"

  cat > "$install_path/bin/orchid" << 'WRAPPER'
#!/usr/bin/env bash
java -jar "$(dirname "$0")/../lib/orchid.jar" "$@"
WRAPPER
  chmod +x "$install_path/bin/orchid"
}
