#!/usr/bin/env bash
# Updates Ubuntu and installs Docker, Docker Compose and Git.
# Written for Ubuntu. Run with: sudo ./scripts/install-docker-ubuntu.sh
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Please run this script with sudo." >&2
  exit 1
fi

apt-get update
apt-get upgrade -y
apt-get install -y docker.io docker-compose git openssl

systemctl enable --now docker

echo "Docker and Docker Compose are installed."
docker --version
docker-compose --version
