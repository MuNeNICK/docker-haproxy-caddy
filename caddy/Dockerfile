FROM caddy:builder AS builder

# プロキシプロトコルを有効にする
RUN xcaddy build --with github.com/mholt/caddy-l4/layer4
RUN xcaddy build --with github.com/mastercactapus/caddy2-proxyprotocol

FROM caddy:latest