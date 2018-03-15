FROM datadog/docker-dd-agent
LABEL maintainer="Unif.io, Inc. <support@unif.io>"

LABEL DATADOG_VERSION="12.5.5223"
LABEL CONSUL_VERSION="1.0.6"
LABEL CONSULTEMPLATE_VERSION="0.19.4"

ENV CONSUL_VERSION=1.0.6
ENV CONSULTEMPLATE_VERSION=0.19.4

RUN apt-get update && \
    apt-get -y install curl unzip && \
    mkdir -p /tmp/build && \
    cd /tmp/build && \
    curl -s --output consul_${CONSUL_VERSION}_linux_amd64.zip https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip && \
    curl -s --output consul_${CONSUL_VERSION}_SHA256SUMS https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS && \
    curl -s --output consul_${CONSUL_VERSION}_SHA256SUMS.sig https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS.sig && \
    curl -s --output consul-template_${CONSULTEMPLATE_VERSION}_linux_amd64.zip https://releases.hashicorp.com/consul-template/${CONSULTEMPLATE_VERSION}/consul-template_${CONSULTEMPLATE_VERSION}_linux_amd64.zip && \
    curl -s --output consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS https://releases.hashicorp.com/consul-template/${CONSULTEMPLATE_VERSION}/consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS && \
    curl -s --output consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS.sig https://releases.hashicorp.com/consul-template/${CONSULTEMPLATE_VERSION}/consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS.sig && \
    gpg --keyserver keys.gnupg.net --recv-keys 91A6E7F85D05C65630BEF18951852D87348FFC4C && \
    gpg --batch --verify consul_${CONSUL_VERSION}_SHA256SUMS.sig consul_${CONSUL_VERSION}_SHA256SUMS && \
    gpg --batch --verify consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS.sig consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS && \
    grep consul_${CONSUL_VERSION}_linux_amd64.zip consul_${CONSUL_VERSION}_SHA256SUMS | sha256sum -c && \
    grep consul-template_${CONSULTEMPLATE_VERSION}_linux_amd64.zip consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS | sha256sum -c && \
    unzip -d /usr/local/bin consul_${CONSUL_VERSION}_linux_amd64.zip && \
    unzip -d /usr/local/bin consul-template_${CONSULTEMPLATE_VERSION}_linux_amd64.zip && \
    cd /tmp && \
    rm -rf /tmp/build

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY config_builder.py /config_builder.py

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["supervisord", "-n", "-c", "/etc/dd-agent/supervisor.conf"]
