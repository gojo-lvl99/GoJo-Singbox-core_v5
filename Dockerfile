# ── Stage 1: Alpine (build-only — thrown away after build)
FROM alpine:3.19 AS downloader

RUN apk add --no-cache wget ca-certificates \
    && LATEST=$(wget -qO- "https://api.github.com/repos/SagerNet/sing-box/releases/latest" \
               | grep '"tag_name"' | cut -d'"' -f4) \
    && VER=${LATEST#v} \
    && wget -q "https://github.com/SagerNet/sing-box/releases/download/${LATEST}/sing-box-${VER}-linux-amd64.tar.gz" \
    && tar xzf "sing-box-${VER}-linux-amd64.tar.gz" \
    && mv "sing-box-${VER}-linux-amd64/sing-box" /sing-box \
    && chmod +x /sing-box

# ── Stage 2: FROM SCRATCH — zero OS, zero shell, binary + certs lang
FROM scratch

COPY --from=downloader /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=downloader /sing-box /sing-box
COPY config.json /config.json

