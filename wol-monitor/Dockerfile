FROM alpine:latest
RUN apk add --no-cache wakeonlan iputils tzdata
WORKDIR /app
COPY monitor.sh .
RUN chmod +x monitor.sh
ENTRYPOINT ["./monitor.sh"]