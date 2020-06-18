FROM alpine AS build

ARG http_proxy
ARG https_proxy
ARG no_proxy

RUN apk add --no-cache krb5-dev gcc musl-dev make
WORKDIR /build
COPY . .
RUN make clean && \
    ./configure --enable-kerberos && \
    make

FROM alpine

RUN apk add --no-cache krb5-libs mandoc
COPY --from=build /build/cntlm /usr/bin/
COPY --from=build /build/doc/cntlm.conf /etc/
COPY --from=build /build/doc/cntlm.1 /usr/share/man/man1/
EXPOSE 3128
CMD [ "cntlm", "-a", "GSS", "-f" ]
