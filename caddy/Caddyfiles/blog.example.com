blog.example.com {
        reverse_proxy <ブログサーバーのIPアドレス>:<ブログサーバーのポート>

        tls {
            on_demand
        }
}
