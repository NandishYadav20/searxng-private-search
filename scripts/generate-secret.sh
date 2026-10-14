#!/usr/bin/env bash
# Creates .env from .env.example (if needed) and fills in a random SEARXNG_SECRET.
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env from .env.example"
fi

if grep -q '^SEARXNG_SECRET=.\+' .env; then
  echo "SEARXNG_SECRET is already set in .env. Nothing to do."
  exit 0
fi

SECRET="$(openssl rand -hex 32)"
sed -i "s|^SEARXNG_SECRET=.*|SEARXNG_SECRET=${SECRET}|" .env
echo "Generated a new SEARXNG_SECRET in .env"
