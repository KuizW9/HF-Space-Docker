# Base image
FROM alpine:latest

# Install required packages
RUN apk add --no-cache curl unzip python3 py3-pip py3-flask bash

# Install XrayR
RUN curl -L https://github.com/XrayR-project/XrayR/releases/download/v0.9.4/XrayR-linux-64.zip -o /tmp/XrayR.zip && \
    unzip /tmp/XrayR.zip -d /usr/local/bin && \
    chmod +x /usr/local/bin/XrayR && \
    rm /tmp/XrayR.zip

# Create XrayR configuration directory
RUN mkdir -p /etc/XrayR/

# Install Cloudflared
RUN curl -L https://github.com/cloudflare/cloudflared/releases/download/2025.8.0/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# Create XrayR configuration
RUN cat <<EOF > /etc/XrayR/config.yml
Log:
  Level: warning
DnsConfigPath: 
RouteConfigPath: 
InboundConfigPath: 
OutboundConfigPath: 
ConnectionConfig:
  Handshake: 4
  ConnIdle: 30
  UplinkOnly: 2
  DownlinkOnly: 4
  BufferSize: 64
Nodes:
   -
     PanelType: "NewV2board"
     ApiConfig:
       ApiHost: "http://alvgw.xyz"
       ApiKey: "n8ae9hw0zqCRfA6ApJ64bgvrT1ict"
       NodeID: 25
       NodeType: V2ray
       Timeout: 30
       EnableVless: false
       EnableXTLS: false
       SpeedLimit: 0
       DeviceLimit: 0
     ControllerConfig:
       ListenIP: 0.0.0.0
       UpdatePeriodic: 10
       EnableDNS: false
       AutoSpeedLimitConfig:
        Limit: 100
        WarnTimes: 5
        LimitSpeed: 20
        LimitDuration: 10
EOF

# Create custom outbound configuration
RUN cat <<EOF > /etc/XrayR/custom_outbound.json
[
  {
    "tag": "IPv4_out",
    "protocol": "freedom",
    "settings": {}
  },
  {
    "tag": "IPv6_out",
    "protocol": "freedom",
    "settings": {
      "domainStrategy": "UseIPv6"
    }
  },
  {
    "tag": "huggingface",
    "protocol": "shadowsocks",
    "settings": {
      "servers": [
        {
          "address": "6231326.xyz",
          "port": 8903,
          "password": "Qoah/O3icCOGS9NBbJ0nLqv9CucSW+wdGngBg4S8UEU=",
          "method": "aes-256-gcm",
          "uot": true
        }
      ]
    },
    "streamSettings": {
      "network": "tcp",
      "security": "none",
      "tcpSettings": {
        "header": {
          "type": "none"
        }
      }
    }
  },
  {
    "protocol": "blackhole",
    "tag": "block"
  }
]
EOF

# Create Flask app directly in the Dockerfile
RUN cat <<EOF > /app.py
from flask import Flask
app = Flask(__name__)
@app.route("/")
def home():
    return "Hello, World!"
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=10086)
EOF

# Set environment variables
ENV PORT=10000
ENV CF_TOKEN=eyJhIjoiNjQ1MTEzYmM3MWQ0MDgwMzA2ZmFmMWJhMmYyZmM4MGEiLCJ0IjoiNTI2ZDdiNWItYmZhMS00YzYxLTgyOTAtNTMwOGI1NzU2MGQ5IiwicyI6IllqZ3hOekZsT0dJdFpqUXlNQzAwWVdZM0xXSXlPR0V0TlRBMVl6RmxZek0zTjJNeSJ9

# Expose specific ports
EXPOSE 10086

# Create entrypoint script
RUN cat <<'EOF' > /entrypoint.sh
#!/bin/bash
nohup /bin/bash -c "cloudflared tunnel --no-autoupdate --edge-ip-version auto --protocol http2 run --token \$CF_TOKEN" > /dev/null 2>&1 &
nohup /bin/bash -c "python /app.py" > /dev/null 2>&1 &
#nohup /bin/bash -c "XrayR --config /etc/XrayR/config.yml" #> /dev/null 2>&1 &
/bin/bash -c "XrayR --config /etc/XrayR/config.yml"
EOF
RUN chmod +x /entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
