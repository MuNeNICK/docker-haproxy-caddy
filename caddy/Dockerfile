FROM caddy:builder AS builder

# モジュールの有効化
RUN xcaddy build --with github.com/mholt/caddy-l4/layer4

FROM caddy:latest
COPY --from=builder /usr/bin/caddy /usr/bin/caddy