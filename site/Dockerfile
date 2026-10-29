FROM alpine:3.24@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a AS builder

ARG APP_VERSION=local
WORKDIR /build

COPY index.html app.js style.css ./
COPY nginx.conf ./
COPY config/env.json ./config/env.json

RUN printf '{"sha":"%s"}\n' "$APP_VERSION" > version.json

FROM nginxinc/nginx-unprivileged:stable-alpine@sha256:f5116ed4606f3eb015dd4a8e28cb9b351476dc0ad4bc6e9f93b19cec130cdf03

ARG APP_VERSION=local

LABEL org.opencontainers.image.source="https://github.com/williamthangavelu0710/azure-devops-platform" \
      org.opencontainers.image.revision="${APP_VERSION}"
USER 0
RUN apk upgrade --no-cache

COPY --from=builder /build/index.html /usr/share/nginx/html/index.html
COPY --from=builder /build/app.js /usr/share/nginx/html/app.js
COPY --from=builder /build/style.css /usr/share/nginx/html/style.css
COPY --from=builder /build/version.json /usr/share/nginx/html/version.json
COPY --from=builder /build/config/env.json /usr/share/nginx/html/config/env.json
COPY --from=builder /build/nginx.conf /etc/nginx/conf.d/default.conf

USER 101
EXPOSE 8080
