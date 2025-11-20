FROM haproxytech/haproxy-ubuntu:latest

# Install and configure rsyslog to capture HAProxy logs
RUN apt-get update && apt-get install -y rsyslog && rm -rf /var/lib/apt/lists/*

# Send local0 facility logs to /var/log/haproxy.log
RUN echo 'local0.* /var/log/haproxy.log' > /etc/rsyslog.d/haproxy.conf

# Enable the rsyslog UDP module so HAProxy can emit logs
RUN sed -i 's/#module(load="imudp")/module(load="imudp")/g' /etc/rsyslog.conf && \
    sed -i 's/#input(type="imudp" port="514")/input(type="imudp" port="514")/g' /etc/rsyslog.conf

# Prepare the log directory with permissive permissions for tailing
RUN mkdir -p /var/log/haproxy && \
    touch /var/log/haproxy.log && \
    chmod 666 /var/log/haproxy.log

# Run rsyslogd in the foreground, start HAProxy, and tail the log to STDOUT
CMD ["/bin/bash", "-c", "rsyslogd -n & haproxy -f /usr/local/etc/haproxy/haproxy.cfg -db & tail -f /var/log/haproxy.log"]
