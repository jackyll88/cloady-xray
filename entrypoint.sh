#!/bin/sh
# Generates /etc/xray/config.json from environment variables, then runs xray.
# Required: UUID (the VLESS client id). Optional: WS_PATH (default /xray), PORT (default 3000).
# Set UUID / WS_PATH as secret env vars in Cloady (Settings -> Environment,
# or: cloady deploy --value UUID=... --value WS_PATH=...). Never commit them.
set -e
if [ -z "$UUID" ]; then
  echo "ERROR: UUID environment variable is not set. Set it in Cloady and redeploy." >&2
  exit 1
fi
WS_PATH="${WS_PATH:-/xray}"
PORT="${PORT:-3000}"
mkdir -p /etc/xray
cat > /etc/xray/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "port": ${PORT},
      "protocol": "vless",
      "settings": {
        "clients": [ { "id": "${UUID}" } ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "${WS_PATH}" }
      }
    }
  ],
  "outbounds": [
    { "protocol": "freedom" }
  ]
}
EOF
exec /usr/local/bin/xray run -config /etc/xray/config.json
