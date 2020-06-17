FROM ubuntu:18.04 AS build

ARG http_proxy
ARG https_proxy
ARG no_proxy

RUN apt-get update && \
    apt-get install -y gcc make build-essential libkrb5-dev groff-base && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
WORKDIR /build
COPY . .
RUN make clean && \
    ./configure --enable-kerberos && \
    make && \
    nroff -t -man doc/cntlm.1 >doc/cntlm.txt

FROM ubuntu:18.04
RUN apt-get update && \
    apt-get install -y libkrb5-3 libgssapi-krb5-2 && \
    apt-get clean all && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY --from=build /build/cntlm /usr/bin/
COPY --from=build /build/doc/cntlm.conf /etc/
COPY --from=build /build/doc/cntlm.txt /
EXPOSE 3128
ENTRYPOINT [ "cntlm", "-a", "GSS", "-f" ]
