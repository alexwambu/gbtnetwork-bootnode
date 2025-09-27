FROM ethereum/client-go:stable

WORKDIR /app

RUN apk add --no-cache curl bash python3

COPY run_bootnode.sh /app/run_bootnode.sh
COPY refresh_enr.sh /app/refresh_enr.sh

RUN chmod +x /app/run_bootnode.sh /app/refresh_enr.sh

EXPOSE 30301 30301/udp 8080

ENTRYPOINT ["/app/run_bootnode.sh"]
