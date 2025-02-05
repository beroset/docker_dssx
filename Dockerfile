FROM debian:bookworm AS builder

LABEL maintainer="Ed Beroset <beroset@ieee.org>"

WORKDIR /tmp/
ENV TZ=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update && \
    apt-get install -y git make cmake g++ uuid-dev
RUN git clone --recurse-submodules --branch fix-klusolve-install https://github.com/beroset/OpenDSS-C.git
WORKDIR /tmp/OpenDSS-C
RUN cmake -DCMAKE_BUILD_TYPE=Release -S . -B build
RUN cmake --build build -t package

FROM debian:bookworm-slim
WORKDIR /root/
COPY --from=builder /tmp/OpenDSS-C/build/OpenDSSX-*.sh .
RUN bash OpenDSSX*.sh --skip-license --prefix=/usr/local/
RUN ldconfig
ENTRYPOINT ["/usr/local/bin/OpenDSSC"]
