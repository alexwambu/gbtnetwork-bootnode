# Stage 1: Build Geth + Bootnode
FROM golang:1.21 as builder

RUN git clone https://github.com/ethereum/go-ethereum.git /go-ethereum
WORKDIR /go-ethereum
RUN make all

# Stage 2: Minimal runtime image
FROM debian:stable-slim

RUN apt-get update && apt-get install -y bash curl python3 netcat && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy binaries
COPY --from=builder /go-ethereum/build/bin/geth /usr/local/bin/geth
COPY --from=builder /go-ethereum/build/bin/bootnode /usr/local/bin/bootnode

# Copy scripts & configs
COPY entrypoint.sh /app/entrypoint.sh
COPY bootnode.key /app/bootnode.key
COPY static-nodes.json /app/static-nodes.json
COPY genesis.json /app/genesis.json

RUN mkdir -p /root/.gbtnetwork \
    && cp /app/static-nodes.json /root/.gbtnetwork/static-nodes.json

RUN chmod +x /app/entrypoint.sh

EXPOSE 9636 30301 30301/udp 30303 30303/udp

ENTRYPOINT ["/app/entrypoint.sh"]
