FROM haproxytech/haproxy-ubuntu:latest

# rsyslog のインストールと設定
RUN apt-get update && apt-get install -y rsyslog && rm -rf /var/lib/apt/lists/*

# rsyslog の設定ファイルを作成
RUN echo 'local0.* /var/log/haproxy.log' > /etc/rsyslog.d/haproxy.conf

# rsyslog の UDP モジュールを有効化
RUN sed -i 's/#module(load="imudp")/module(load="imudp")/g' /etc/rsyslog.conf && \
    sed -i 's/#input(type="imudp" port="514")/input(type="imudp" port="514")/g' /etc/rsyslog.conf

# ログディレクトリとログファイルを作成
RUN mkdir -p /var/log/haproxy && \
    touch /var/log/haproxy.log && \
    chmod 666 /var/log/haproxy.log

# rsyslogd をフォアグラウンドで起動、HAProxy をバックグラウンド実行し、tail でログを STDOUT に出力
CMD ["/bin/bash", "-c", "rsyslogd -n & haproxy -f /usr/local/etc/haproxy/haproxy.cfg -db & tail -f /var/log/haproxy.log"]