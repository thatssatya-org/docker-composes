FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wakeonlan \
    iputils-ping \
    tzdata && \
    netbase && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY monitor.sh .

RUN chmod +x monitor.sh

ENTRYPOINT ["./monitor.sh"]