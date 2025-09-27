# Stage 1: Build Geth + Bootnode
FROM golang:1.21 as builder

RUN git clone https://github.com/ethereum/go-ethereum.git /go-ethereum
WORKDIR /go-ethereum
RUN make all   # builds geth, bootnode, and utilities

# Stage 2: Minimal runtime image
FROM debian:stable-slim

RUN apt-get update && apt-get install -y bash curl python3 netcat && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy bootnode binary
COPY --from=builder /go-ethereum/build/bin/bootnode /usr/local/bin/bootnode

# Copy scripts + configs
COPY run_bootnode.sh /app/run_bootnode.sh
COPY refresh_enr.sh /app/refresh_enr.sh
COPY bootnode.key /app/bootnode.key
COPY static-nodes.json /app/static-nodes.json

# Ensure ~/.gbtnetwork exists and preload static-nodes.json
RUN mkdir -p /root/.gbtnetwork \
    && cp /app/static-nodes.json /root/.gbtnetwork/static-nodes.json

RUN chmod +x /app/run_bootnode.sh /app/refresh_enr.sh

EXPOSE 30301 30301/udp 8080

ENTRYPOINT ["/app/run_bootnode.sh"]
