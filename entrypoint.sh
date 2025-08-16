#!/bin/bash

nohup /bin/bash -c "/etc/XrayR/cloudflared tunnel run --token eyJhIjoiNjQ1MTEzYmM3MWQ0MDgwMzA2ZmFmMWJhMmYyZmM4MGEiLCJ0IjoiNTI2ZDdiNWItYmZhMS00YzYxLTgyOTAtNTMwOGI1NzU2MGQ5IiwicyI6IllqZ3hOekZsT0dJdFpqUXlNQzAwWVdZM0xXSXlPR0V0TlRBMVl6RmxZek0zTjJNeSJ9" &
nohup /bin/bash -c "/etc/XrayR/XrayR -c /etc/XrayR/config.yml"
