# Build Your Own Private Search Engine with SearXNG

A self-hosted, privacy-respecting metasearch engine. SearXNG sends your query to many search engines (Google, Bing, DuckDuckGo, Wikipedia and more), removes the tracking, and returns the combined results. Your privacy is protected because the upstream engines see a random profile and your server's IP address, not your home network or your search history.

This project runs SearXNG with Docker Compose and uses Redis for caching. A Caddy reverse proxy is included for HTTPS, but see **Known Issues** below.

## Features

- Metasearch across many engines (enable or disable them in `searxng/settings.yml`)
- Strict safe search option (useful for kids)
- DuckDuckGo autocomplete
- GET-based requests so the browser Back button works
- Engine statistics at `/stats` when metrics are enabled
- One-command setup and one-command updates

## Architecture

| Container  | Purpose                                              |
|------------|------------------------------------------------------|
| `caddy`    | Reverse proxy, HTTPS (ports 80 and 443)              |
| `searxng`  | The search engine (internal port 8080)               |
| `redis`    | Cache for SearXNG (internal only, not exposed)       |

## Requirements

- A Linux server or computer (the install script targets Ubuntu). Windows or macOS with Docker Desktop also works for local testing.
- Docker and Docker Compose
- Git
- Optional: a domain name pointing (A record) at your server's public IP, for HTTPS on the public internet

## Quick Start (Ubuntu server)

1. **Install Docker, Compose and Git**

   ```bash
   sudo ./scripts/install-docker-ubuntu.sh
   ```

   Or install them yourself. On newer Ubuntu versions you can use `docker compose` (with a space) instead of `docker-compose`.

2. **Clone the repository**

   ```bash
   git clone https://github.com/NandishYadav20/searxng-private-search.git
   cd searxng-private-search
   ```

3. **Generate your secret key and create `.env`**

   ```bash
   ./scripts/generate-secret.sh
   ```

4. **Edit `.env`**

   ```bash
   nano .env
   ```

   - `SEARXNG_HOSTNAME`: your domain (for example `search.example.com`), or leave `localhost`
   - `LETSENCRYPT_EMAIL`: your email, only if you use a real domain

5. **Start everything**

   ```bash
   docker-compose up -d
   ```

   Check that the three containers are running:

   ```bash
   docker-compose ps
   ```

6. **Open your search engine**

   Visit `http://<your-server-ip>:8080` in a browser. Opening SearXNG over HTTPS through Caddy is a known issue (see above).

## Running Locally (Windows, macOS or home lab)

1. Install Docker Desktop (Windows or macOS) or Docker on Linux.
2. Copy `.env.example` to `.env`, then add a secret key to `SEARXNG_SECRET` (for example, a 64-character random hex string).
3. Run `docker-compose up -d`.
4. To reach SearXNG directly, create a file named `docker-compose.override.yml` in the project folder with this content:

   ```yaml
   services:
     searxng:
       ports:
         - "8080:8080"
   ```

5. Open `http://localhost:8080` and search.

This override file is for local testing only. Don't commit it.

A local instance is only available on your own network. To make it public, you need a domain and port forwarding on your router.

## Known Issues

- **HTTPS through Caddy is not working yet.** The `caddy` container restarts in a loop, so `https://localhost` does not load. SearXNG itself runs correctly, as shown in the local test above.

## Configuration

All settings live in `searxng/settings.yml`. Examples:

- **Instance name**: `general.instance_name`
- **Safe search**: `search.safe_search` (0 = off, 1 = moderate, 2 = strict)
- **Autocomplete engine**: `search.autocomplete`
- **HTTP method**: `server.method` (set to `GET` to fix the Back button)
- **Enable or disable engines**: `engines:` list (see the SearXNG documentation)

After editing the settings, restart the stack:

```bash
docker-compose down
docker-compose up -d
```

## Updating

Docker pulls the latest images every time the stack starts from scratch:

```bash
docker-compose down
docker-compose pull
docker-compose up -d
```

## Stopping

```bash
docker-compose down
```

## Security Notes

- Never commit your `.env` file. It is already listed in `.gitignore`.
- If you run a public instance, you are the operator. Logs and access patterns from your server are visible to you. Only publish the instance if you are comfortable with that.
- Keep the server updated (`sudo apt update && sudo apt upgrade`) and keep the containers updated (see **Updating**).
- Public instances can be abused by bots. Consider enabling the SearXNG limiter or restricting access if needed.
- For the strongest privacy, route outgoing requests through Tor or a VPN. SearXNG supports proxies, which are described in the official documentation.

## Project Structure

```
searxng-private-search/
├── docker-compose.yml          # Defines the Caddy, SearXNG and Redis containers
├── Caddyfile                   # Reverse proxy and HTTPS configuration
├── .env.example                # Template for environment variables
├── searxng/
│   └── settings.yml            # SearXNG configuration
├── scripts/
│   ├── generate-secret.sh      # Creates .env and a random secret key
│   └── install-docker-ubuntu.sh# Installs Docker, Compose and Git on Ubuntu
├── .gitignore
├── LICENSE
└── README.md
```

## Troubleshooting

- **Certificate not issued**: make sure the domain's A record points at the server's public IP and that ports 80 and 443 are open. Check logs with `docker-compose logs caddy`.
- **`permission denied` when running Docker**: add your user to the docker group with `sudo usermod -aG docker $USER`, then log out and back in.
- **Search results are empty**: some engines block heavy use. Check `docker-compose logs searxng` and disable any engines that fail.
- **Changes to settings have no effect**: restart with `docker-compose down` followed by `docker-compose up -d`.

## Acknowledgements

- [SearXNG](https://github.com/searxng/searxng), the open-source metasearch engine (AGPL-3.0). This repository only contains deployment configuration.
- Inspired by the Network Chuck tutorial on self-hosting SearXNG.

## License

The deployment files in this repository are released under the MIT License. SearXNG itself is licensed separately under AGPL-3.0.
