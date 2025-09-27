# Stage 1: Build Geth + Bootnode
FROM golang:1.21 as builder

RUN git clone https://github.com/ethereum/go-ethereum.git /go-ethereum
WORKDIR /go-ethereum
RUN make all

# Stage 2: Minimal runtime image
FROM debian:stable-slim

RUN apt-get update && apt-get install -y bash curl python3 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy binaries
COPY --from=builder /go-ethereum/build/bin/geth /usr/local/bin/geth
COPY --from=builder /go-ethereum/build/bin/bootnode /usr/local/bin/bootnode

# Copy scripts, configs, and keys
COPY run_bootnode.sh /app/run_bootnode.sh
COPY run_gbtnetwork.sh /app/run_gbtnetwork.sh
COPY refresh_enr.sh /app/refresh_enr.sh
COPY bootnode.key /app/bootnode.key
COPY static-nodes.json /app/static-nodes.json
COPY genesis.json /app/genesis.json

# Symlink static-nodes.json into ~/.gbtnetwork
RUN mkdir -p /root/.gbtnetwork \
    && ln -sf /app/static-nodes.json /root/.gbtnetwork/static-nodes.json

RUN chmod +x /app/*.sh

EXPOSE 30301/udp 30303 8545 9636 8080

ENTRYPOINT ["/app/run_gbtnetwork.sh"]
