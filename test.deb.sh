#!/bin/bash

INSTALL_PATH="/dev/sda1/pufferpanel"

unknown_os () {
  echo "Unfortunately, your operating system distribution and version are not supported by this script."
  exit 1
}

gpg_check () {
  echo "Checking for gpg..."
  if ! command -v gpg > /dev/null; then
    echo "Installing gnupg..."
    apt-get install -y gnupg || { echo "Failed to install gnupg."; exit 1; }
  fi
}

curl_check () {
  echo "Checking for curl..."
  if ! command -v curl > /dev/null; then
    echo "Installing curl..."
    apt-get install -y curl || { echo "Failed to install curl."; exit 1; }
  fi
}

detect_os () {
  if [[ -z "${os}" && -z "${dist}" ]]; then
    if [ -e /etc/os-release ]; then
      . /etc/os-release
      os=${ID}
      dist=${VERSION_CODENAME:-$VERSION_ID}
    else
      unknown_os
    fi
  fi
  echo "Detected OS: $os/$dist"
}

setup_repo () {
  echo "Setting up repository..."
  gpg_key_url="https://packagecloud.io/pufferpanel/pufferpanel/gpgkey"
  apt_config_url="https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/config_file.list?os=${os}&dist=${dist}&source=script"
  apt_source_path="/etc/apt/sources.list.d/pufferpanel.list"
  apt_keyring="/etc/apt/keyrings/pufferpanel-archive-keyring.gpg"

  curl -fsSL "$gpg_key_url" | gpg --dearmor > "$apt_keyring"
  chmod 0644 "$apt_keyring"
  curl -sSf "$apt_config_url" > "$apt_source_path" || { echo "Failed to download repo config."; exit 1; }
}

install_pufferpanel () {
  echo "Installing PufferPanel..."
  apt-get update && apt-get install -y pufferpanel || { echo "Failed to install PufferPanel."; exit 1; }
  echo "PufferPanel installed."
}

configure_pufferpanel () {
  echo "Configuring PufferPanel..."
  systemctl stop pufferpanel
  mkdir -p "$INSTALL_PATH"
  cp -r /etc/pufferpanel/* "$INSTALL_PATH"/
  sed -i "s|/etc/pufferpanel|$INSTALL_PATH|g" /etc/systemd/system/pufferpanel.service
  systemctl daemon-reload
  systemctl start pufferpanel
  echo "PufferPanel configured to use $INSTALL_PATH."
}

main () {
  detect_os
  curl_check
  gpg_check
  setup_repo
  install_pufferpanel
  configure_pufferpanel
  echo "Installation complete."
}

main
