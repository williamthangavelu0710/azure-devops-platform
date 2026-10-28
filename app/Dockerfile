FROM alpine:3.22 AS builder

ARG GIT_SHA=local
WORKDIR /build

COPY index.html app.js ./
COPY nginx.conf ./
COPY config/env.json ./config/env.json

RUN printf '{"sha":"%s"}\n' "$GIT_SHA" > version.json

FROM nginxinc/nginx-unprivileged:stable-alpine

COPY --from=builder /build/index.html /usr/share/nginx/html/index.html
COPY --from=builder /build/app.js /usr/share/nginx/html/app.js
COPY --from=builder /build/version.json /usr/share/nginx/html/version.json
COPY --from=builder /build/config/env.json /usr/share/nginx/html/config/env.json
COPY --from=builder /build/nginx.conf /etc/nginx/conf.d/default.conf

USER 101
EXPOSE 8080
