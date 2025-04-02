FROM "alpine"

LABEL org.opencontainers.image.authors="kratix@syntasso.io"
LABEL org.opencontainers.image.source=https://github.com/syntasso/kratix-marketplace

RUN [ "mkdir", "/tmp/transfer" ]
RUN apk update && apk add --no-cache yq

ADD resources/ /tmp/transfer/
RUN chmod +x /tmp/transfer/* && mv /tmp/transfer/* /usr/local/bin/

CMD [ "sh", "-c", "./execute-pipeline" ]
ENTRYPOINT []
