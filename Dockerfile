# syntax=docker/dockerfile:1.4
FROM alpine:latest AS stage1

RUN apk add --no-cache git openssh-client
RUN mkdir -p -m 0700 ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN --mount=type=ssh git clone git@github.com:hubert00100/pawcho6.git /src

ARG VERSION=1.0
ENV APP_VERSION=$VERSION

WORKDIR /src

RUN echo "<html><head><meta charset='UTF-8'></head><body style='font-family: sans-serif; padding: 50px; line-height: 1.6;'>" > index.html && \
    echo "<h1>PAwChO - Laboratorium 6 (z repo pawcho6)</h1>" >> index.html && \
    echo "<p><b>Wersja aplikacji:</b> ${APP_VERSION}</p>" >> index.html && \
    echo "<p><b>Adres serwera:</b> <span id='ip'></span></p>" >> index.html && \
    echo "<script>document.getElementById('ip').innerText = window.location.hostname;</script>" >> index.html && \
    echo "</body></html>" >> index.html

FROM nginx:alpine

LABEL author="Hubert Łuszczew"

COPY --from=stage1 /src/index.html /usr/share/nginx/html/index.html

HEALTHCHECK --interval=10s --timeout=3s \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

EXPOSE 80
