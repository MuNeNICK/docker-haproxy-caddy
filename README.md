# リバースプロキシサーバー設定 / Reverse Proxy Server Configuration

このプロジェクトは、HAProxyとCaddyを使用したリバースプロキシシステムを構築するためのDocker Compose設定です。外部からのトラフィックを受け付け、指定されたバックエンドサービスに適切に転送します。

This project contains Docker Compose configuration for building a reverse proxy system using HAProxy and Caddy. It accepts external traffic and appropriately forwards it to specified backend services.

## 機能 / Features

- HTTP(80)からHTTPS(443)への自動リダイレクト / Automatic redirection from HTTP(80) to HTTPS(443)
- SNI(Server Name Indication)ベースのルーティング / SNI-based routing
- オンデマンドTLS証明書の自動取得と管理 / Automatic acquisition and management of on-demand TLS certificates
- ProxyProtocolを使用したクライアントIPの保持 / Client IP preservation using Proxy Protocol
- 複数バックエンドサービスへの転送 / Forwarding to multiple backend services

## アーキテクチャ / Architecture

```
クライアント → HAProxy(80/443) → Caddy → バックエンドサービス
Client → HAProxy(80/443) → Caddy → Backend Services
```

- **HAProxy**: フロントエンドとしてすべてのトラフィックを受け付け、必要に応じてSNIベースでルーティングします / Accepts all traffic as the frontend and routes based on SNI when needed
- **Caddy**: TLS終端処理とリバースプロキシを担当し、バックエンドサービスにトラフィックを転送します / Handles TLS termination and reverse proxying, forwarding traffic to backend services

## 前提条件 / Prerequisites

- Docker
- Docker Compose
- 公開サーバー（パブリックIPアドレスが必要） / Public server (with a public IP address)
- 設定するドメイン名のDNS設定 / DNS configuration for the domain names to be set up

## セットアップ方法 / Setup Instructions

1. リポジトリをクローン / Clone the repository
   ```
   git clone [リポジトリURL]
   cd [プロジェクト名]
   ```

2. 設定ファイルを編集 / Edit configuration files
   - `caddy/Caddyfile`: メールアドレスを実際のものに変更 / Replace the email address with a real one
   - `caddy/Caddyfiles/blog.example.com`: ドメイン名、バックエンドサーバーのIPアドレスとポートを設定 / Configure domain name, backend server IP address and port

3. サービスを起動 / Start services
   ```
   docker-compose up -d
   ```

4. ログを確認 / Check logs
   ```
   docker-compose logs -f
   ```

## 新しいサービスの追加方法 / How to Add New Services

1. Caddyfilesディレクトリに新しいドメイン用の設定ファイルを作成 / Create a configuration file for the new domain in the Caddyfiles directory:
   ```
   touch caddy/Caddyfiles/newservice.example.com.Caddyfile
   ```

2. 設定ファイルを編集 / Edit the configuration file:
   ```
   newservice.example.com {
       reverse_proxy <サービスのIPアドレス>:<サービスのポート>

       tls {
           on_demand
       }
   }
   ```

3. (オプション) HAProxyの設定でSNIベースのルーティングを追加 / (Optional) Add SNI-based routing in HAProxy configuration:
   `haproxy/haproxy.cfg` ファイルの frontend https セクションに / In the frontend https section of the `haproxy/haproxy.cfg` file:
   ```
   use_backend newservice_backend if { req_ssl_sni -m end newservice.example.com }
   ```
   
   そして、新しいバックエンドセクションを追加 / And add a new backend section:
   ```
   backend newservice_backend
     mode tcp
     server newservice <サービスのIPアドレス>:443 sni req_ssl_sni
   ```

4. 設定を再読み込み / Reload configuration:
   ```
   docker-compose restart
   ```

## トラブルシューティング / Troubleshooting

### ログの確認 / Checking Logs
```
# HAProxyのログ / HAProxy logs
docker-compose logs haproxy

# Caddyのログ / Caddy logs
docker-compose logs caddy
```

### TLS証明書の問題 / TLS Certificate Issues
Caddyは自動的にLet's Encryptから証明書を取得します。DNSの設定が正しいことと、指定したメールアドレスが有効であることを確認してください。
Caddy automatically obtains certificates from Let's Encrypt. Make sure your DNS settings are correct and the specified email address is valid.

### バックエンドサービスに接続できない / Cannot Connect to Backend Services
バックエンドサービスのIPアドレスとポートが正しいことを確認してください。また、ファイアウォール設定でそれらのポートが開いていることを確認してください。
Verify that the IP address and port of the backend service are correct. Also, check that those ports are open in your firewall settings.

## 注意事項 / Notes

- 本番環境で使用する前に、セキュリティ設定を十分に確認してください / Review security settings thoroughly before using in a production environment
- `<メールアドレス>`、`<ブログサーバーのIPアドレス>`、`<ブログサーバーのポート>` などのプレースホルダーは、実際の値に置き換えてください / Replace placeholders such as `<メールアドレス>` (email address), `<ブログサーバーのIPアドレス>` (blog server IP address), and `<ブログサーバーのポート>` (blog server port) with actual values