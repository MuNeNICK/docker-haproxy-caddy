# Reverse Proxy Server Configuration

This repository ships a Docker Compose stack that builds an HAProxy + Caddy reverse proxy tier. HAProxy terminates the TCP connections on ports 80/443, forwards traffic to Caddy via Proxy Protocol, and Caddy handles TLS, HTTP routing, and error responses via a dedicated `error-pages` container.

## Features

- Automatic HTTP -> HTTPS redirection
- SNI-based routing controlled by HAProxy
- On-demand TLS certificates managed by Caddy
- Client IP preservation through Proxy Protocol
- Dedicated `error-pages` service that serves every error response
- Extensible Caddyfile snippets per domain under `caddy/Caddyfiles`

## Architecture

```
Client -> HAProxy (80/443) -> Caddy -> Backend services
```

- **HAProxy** (see `haproxy/haproxy.cfg`) accepts inbound traffic, negotiates TLS at the TCP layer, and forwards connections based on SNI when needed.
- **Caddy** (see `caddy/Caddyfile`) terminates HTTP, performs reverse proxying, issues TLS certificates, and forwards errors to the `error-pages` container.
- **error-pages** provides friendly status pages for every error surfaced by Caddy.

## Prerequisites

- Docker and Docker Compose
- Publicly reachable host (public IP)
- DNS records pointing to that host for every domain you plan to serve

## Setup

1. Clone the repository and switch into it.
   ```
   git clone <repo-url>
   cd docker-haproxy-caddy
   ```
2. Update configuration files:
   - `caddy/Caddyfile`: replace the placeholder email with a real one (used for Let's Encrypt) and adjust any global settings you require.
   - Add or edit domain-specific snippets in `caddy/Caddyfiles/*.Caddyfile`. A sample file (`caddy/Caddyfiles/blog.example.com`) is provided.
3. Start the stack.
   ```
   docker-compose up -d
   ```
4. Tail logs as needed.
   ```
   docker-compose logs -f haproxy
   docker-compose logs -f caddy
   docker-compose logs -f error-pages
   ```

## Adding a New Service

1. Create a new file under `caddy/Caddyfiles`, for example `newservice.example.com.Caddyfile`:
   ```
   newservice.example.com {
       reverse_proxy <service-ip>:<service-port>

       tls {
           on_demand
       }
   }
   ```
2. (Optional) Update `haproxy/haproxy.cfg` to add explicit SNI routing before the default backend:
   ```
   use_backend newservice_backend if { req_ssl_sni -m end newservice.example.com }

   backend newservice_backend
     mode tcp
     server newservice <service-ip>:443 sni req_ssl_sni
   ```
3. Reload the stack so both HAProxy and Caddy pick up the changes.
   ```
   docker-compose restart
   ```

## Troubleshooting

- **Certificates are not issued**: verify DNS records point to this host and that the email configured in `caddy/Caddyfile` is valid.
- **Backend cannot be reached**: confirm the IP/port in your Caddyfile snippet is correct and that the backend's firewall allows the traffic.
- **Logs are empty**: ensure `haproxy` and `caddy` containers are running and inspect `docker-compose logs <service>` for errors.

## Notes

- Replace every remaining placeholder (such as `<repo-url>`, `<service-ip>`, `<service-port>`, etc.) with real values before deploying.
- Review security posture and tighten firewall rules before running this stack in production.
