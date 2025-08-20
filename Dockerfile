# Release
FROM alpine

# Install necessary packages and clean up
RUN apk --update --no-cache add \
        tzdata \
        ca-certificates \
        wget \
        unzip \
        bash \
        python3 \
        py3-pip \
        py3-flask \
        openssl \
        curl \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && rm -rf /var/cache/apk/*

# Create directory for XrayR
RUN mkdir /etc/XrayR

# Download XrayR and cloudflared
RUN wget -O XrayR-linux-64.zip https://github.com/XrayR-project/XrayR/releases/download/v0.9.4/XrayR-linux-64.zip \
    && unzip XrayR-linux-64.zip -d /etc/XrayR \
    && wget -O /etc/XrayR/cloudflared https://github.com/cloudflare/cloudflared/releases/download/2025.8.0/cloudflared-linux-amd64

#RUN rm /etc/Xray/config.yml /etc/XrayR/custom_outbound.json -irf
ENV CF_TOKEN=eyJhIjoiNjQ1MTEzYmM3MWQ0MDgwMzA2ZmFmMWJhMmYyZmM4MGEiLCJ0IjoiNTI2ZDdiNWItYmZhMS00YzYxLTgyOTAtNTMwOGI1NzU2MGQ5IiwicyI6IllqZ3hOekZsT0dJdFpqUXlNQzAwWVdZM0xXSXlPR0V0TlRBMVl6RmxZek0zTjJNeSJ9
# Create entrypoint script
RUN cat <<EOF > /etc/XrayR/entrypoint.sh
#!/bin/bash
#set -e
nohup /bin/bash -c "/etc/XrayR/cloudflared tunnel --region us --no-autoupdate --edge-ip-version auto --protocol http2 run --token \$CF_TOKEN" > /dev/null 2>&1 &
nohup /bin/bash -c "/etc/XrayR/XrayR --config /etc/XrayR/config.yml" #> /dev/null 2>&1 &
#nohup /bin/bash -c "python /etc/XrayR/app.py" > /dev/null 2>&1 &
echo "-------------DONE-------------"
EOF

# Create Flask application
RUN cat <<EOF > /etc/XrayR/app.py
from flask import Flask, redirect
app = Flask(__name__)

@app.route('/')
def home():
    return "hello world"
    #return redirect("https://shop.alvgw.xyz")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=7860)
EOF

# Create configuration files
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
        Limit: 100 # Warned speed. Set to 0 to disable AutoSpeedLimit (mbps)
        WarnTimes: 5 # After (WarnTimes) consecutive warnings, the user will be limited. Set to 0 to punish overspeed user immediately.
        LimitSpeed: 20 # The speedlimit of a limited user (unit: mbps)
        LimitDuration: 10 # How many minutes will the limiting last (unit: minute)
EOF

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

# Set permissions
RUN chmod +x /etc/XrayR/entrypoint.sh /etc/XrayR/app.py /etc/XrayR/cloudflared /etc/XrayR/XrayR

# Expose the port
EXPOSE 7860

# Run the entrypoint script
CMD ["/bin/bash", "-c", "/etc/XrayR/entrypoint.sh"]