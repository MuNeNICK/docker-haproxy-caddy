FROM caddy:builder AS builder

# Enable the caddy-l4 module so HAProxy can speak Proxy Protocol
RUN xcaddy build --with github.com/mholt/caddy-l4/layer4

FROM caddy:latest
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
