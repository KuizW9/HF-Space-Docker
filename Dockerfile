# Release
FROM  alpine
# 安装必要的工具包
RUN  apk --update --no-cache add tzdata ca-certificates \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
RUN apk --no-cache add wget unzip bash python3 py3-pip py3-flask openssl curl
RUN mkdir /etc/XrayR
RUN wget -O XrayR-linux-64.zip https://github.com/XrayR-project/XrayR/releases/download/v0.9.4/XrayR-linux-64.zip
RUN unzip XrayR-linux-64.zip -d /etc/XrayR
RUN wget -O /etc/XrayR/cloudflared https://github.com/cloudflare/cloudflared/releases/download/2025.8.0/cloudflared-linux-amd64
#RUN chmod +x /etc/XrayR/entrypoint.sh
#COPY entrypoint.sh /etc/XrayR/entrypoint.sh
RUN cat <<EOF > /etc/XrayR/entrypoint.sh
#!/bin/bash
nohup /bin/bash -c "/etc/XrayR/cloudflared tunnel --no-autoupdate --edge-ip-version auto --protocol http2 run --token eyJhIjoiNjQ1MTEzYmM3MWQ0MDgwMzA2ZmFmMWJhMmYyZmM4MGEiLCJ0IjoiNTI2ZDdiNWItYmZhMS00YzYxLTgyOTAtNTMwOGI1NzU2MGQ5IiwicyI6IllqZ3hOekZsT0dJdFpqUXlNQzAwWVdZM0xXSXlPR0V0TlRBMVl6RmxZek0zTjJNeSJ9" > /dev/null 2>&1 &
nohup /bin/bash -c "/etc/XrayR/XrayR -c /etc/XrayR/config.yml" > /dev/null 2>&1
nohup /bin/bash -c "python /etc/XrayR/app.py" > /dev/null 2>&1
EOF
RUN cat <<EOF > /etc/XrayR/app.py
from flask import Flask
app = Flask(__name__)
@app.route('/')
def home():
    #return "Hello, Flask! This is running on port 7860."
    return redirect("https://shop.alvgw.xyz")
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=7860)
EOF
RUN cat <<EOF > /etc/XrayR/config.yml
Log:
  Level: warning # Log level: none, error, warning, info, debug 
  AccessPath: # /etc/XrayR/access.Log
  ErrorPath: # /etc/XrayR/error.log
DnsConfigPath: # /etc/XrayR/dns.json # Path to dns config, check https://xtls.github.io/config/dns.html for help
RouteConfigPath: # /etc/XrayR/route.json # Path to route config, check https://xtls.github.io/config/routing.html for help
InboundConfigPath: # /etc/XrayR/custom_inbound.json # Path to custom inbound config, check https://xtls.github.io/config/inbound.html for help
OutboundConfigPath: # /etc/XrayR/custom_outbound.json # Path to custom outbound config, check https://xtls.github.io/config/outbound.html for help
ConnectionConfig:
  Handshake: 4 # Handshake time limit, Second
  ConnIdle: 30 # Connection idle time limit, Second
  UplinkOnly: 2 # Time limit when the connection downstream is closed, Second
  DownlinkOnly: 4 # Time limit when the connection is closed after the uplink is closed, Second
  BufferSize: 64 # The internal cache size of each connection, kB
Nodes:
   -
     PanelType: "NewV2board" # Panel type: SSpanel, V2board, NewV2board, PMpanel, Proxypanel, V2RaySocks
     ApiConfig:
       ApiHost: "http://alvgw.xyz"
       ApiKey: "n8ae9hw0zqCRfA6ApJ64bgvrT1ict"
       NodeID: 25
       NodeType: V2ray  # Node type: V2ray, Shadowsocks, Trojan
       Timeout: 30 # Timeout for the api request
       EnableVless: false # Enable Vless for V2ray Type
       EnableXTLS: false # Enable XTLS for V2ray and Trojan
       SpeedLimit: 0 # Mbps, Local settings will replace remote settings
       DeviceLimit: 0 # Local settings will replace remote settings
     ControllerConfig:
       ListenIP: 0.0.0.0 # IP address you want to listen
       UpdatePeriodic: 10 # Time to update the nodeinfo, how many sec.
       EnableDNS: false # Use custom DNS config, Please ensure that you set the dns.json well
EOF

RUN chmod +x /etc/XrayR/entrypoint.sh
RUN chmod +x /etc/XrayR/app.py
RUN chmod +x /etc/XrayR/cloudflared
RUN chmod +x /etc/XrayR/XrayR

EXPOSE 7860
CMD ["/bin/bash", "-c", "/etc/XrayR/entrypoint.sh"] 
