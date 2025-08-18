#!/bin/bash
#tunnel --no-autoupdate --edge-ip-version auto --protocol http2 run
nohup /bin/bash -c "/etc/XrayR/cloudflared tunnel --no-autoupdate --edge-ip-version auto --protocol http2 run --token eyJhIjoiNjQ1MTEzYmM3MWQ0MDgwMzA2ZmFmMWJhMmYyZmM4MGEiLCJ0IjoiNTI2ZDdiNWItYmZhMS00YzYxLTgyOTAtNTMwOGI1NzU2MGQ5IiwicyI6IllqZ3hOekZsT0dJdFpqUXlNQzAwWVdZM0xXSXlPR0V0TlRBMVl6RmxZek0zTjJNeSJ9" > /dev/null 2>&1 &
nohup /bin/bash -c "/etc/XrayR/XrayR -c /etc/XrayR/config.yml" > /dev/null 2>&1

nohup /bin/bash -c "python /etc/XrayR/app.py" > /dev/null 2>&1
