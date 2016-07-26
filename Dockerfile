FROM ubuntu:xenial

ENV PATH ${PATH}:/usr/local/go/bin
ENV GOPATH ${HOME}/go
ENV SRC_PATH ${GOPATH}/src/autoscaler
ENV BIN_DIR /data/bin

ADD bin/docker-entrypoint.sh /data/bin/

RUN \
    adduser --disabled-password --gecos '' kube && \
    DEBIAN_FRONTEND=noninteractive apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -y upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install freetds-dev && \
    dpkg -l > /var/tmp/dpkg_pre_deps.txt && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install wget make git gcc && \
    wget -nv --no-check-certificate https://storage.googleapis.com/golang/go1.6.3.linux-amd64.tar.gz && \
    shasum -a 256 go1.6.3.linux-amd64.tar.gz | grep cdde5e08530c0579255d6153b08fdb3b8e47caabbe717bc7bcd7561275a87aeb && \
    tar -C /usr/local -xzf go1.6.3.linux-amd64.tar.gz && \
    rm -f go1.6.3.linux-amd64.tar.gz && \
    mkdir -p ${GOPATH}/{src,bin,pkg} && \
    git clone --depth 1 https://github.com/mbogus/kube-amqp-autoscale.git ${SRC_PATH} && \
    cd ${SRC_PATH} && \
    make depend && \
    make test && \
    make && \
    mv .build/autoscale ${BIN_DIR} && \
    chmod +x ${BIN_DIR}/* && \
    cd ${HOME} && \
    rm -rf ${GOPATH} && \
    rm -rf /usr/local/go && \
    chown -Rf kube:kube /data && \
    DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove wget make git gcc ifupdown iproute2 less manpages netbase openssh-client perl perl-modules-5.22 rename xauth && \
    DEBIAN_FRONTEND=noninteractive apt-get autoremove -y --purge && \
    DEBIAN_FRONTEND=noninteractive apt-get clean -y && \
    dpkg -l > /var/tmp/dpkg_post_deps.txt && \
    diff /var/tmp/dpkg_pre_deps.txt /var/tmp/dpkg_post_deps.txt && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV GOPATH= SRC_PATH=

VOLUME /etc/default
VOLUME /data/db

USER kube
WORKDIR /data/bin

ENTRYPOINT ["/data/bin/docker-entrypoint.sh"]
CMD [""]
