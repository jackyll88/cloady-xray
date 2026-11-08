# Multi-stage build: the official xray image has no shell, so we fetch the
# official binary and copy it into Alpine (which HAS a shell).
# Stage 1: download + extract the official xray binary.
FROM alpine:3.20 AS downloader
ARG XRAY_VERSION=v26.10.31
RUN apk add --no-cache curl unzip \
    && (curl -fsSL -o /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip" \
        || curl -fsSL -o /tmp/xray.zip "https://gh-proxy.com/https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip") \
    && unzip /tmp/xray.zip -d /tmp/xray \
    && chmod +x /tmp/xray/xray

# Stage 2: minimal runtime.
FROM alpine:3.20
RUN apk add --no-cache ca-certificates
COPY --from=downloader /tmp/xray/xray /usr/local/bin/xray
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
EXPOSE 3000
ENTRYPOINT ["/entrypoint.sh"]
