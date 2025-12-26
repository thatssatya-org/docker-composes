FROM alpine:latest
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache wakeonlan iputils tzdata bash
WORKDIR /app
COPY monitor.sh .
RUN chmod +x monitor.sh
ENTRYPOINT ["./monitor.sh"]