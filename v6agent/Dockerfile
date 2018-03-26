FROM datadog/agent as dd_base
LABEL maintainer="Unif.io, Inc. <support@unif.io>"

LABEL DATADOG_VERSION="6.1.0"
LABEL CONSUL_VERSION="1.0.6"
LABEL CONSULTEMPLATE_VERSION="0.19.4"

ENV CONSUL_VERSION=1.0.6
ENV CONSULTEMPLATE_VERSION=0.19.4
ENV HASHI_KEY_URL https://keybase.io/hashicorp/key.asc

ADD https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip consul_${CONSUL_VERSION}_linux_amd64.zip
ADD https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS consul_${CONSUL_VERSION}_SHA256SUMS
ADD https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_SHA256SUMS.sig consul_${CONSUL_VERSION}_SHA256SUMS.sig

ADD https://releases.hashicorp.com/consul-template/${CONSULTEMPLATE_VERSION}/consul-template_${CONSULTEMPLATE_VERSION}_linux_amd64.zip consul-template_${CONSULTEMPLATE_VERSION}_linux_amd64.zip
ADD https://releases.hashicorp.com/consul-template/${CONSULTEMPLATE_VERSION}/consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS
ADD https://releases.hashicorp.com/consul-template/${CONSULTEMPLATE_VERSION}/consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS.sig consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS.sig

RUN mkdir -p usr/local/bin \
  && apt-get update \
  && apt-get install -y gpg unzip \
  && curl $HASHI_KEY_URL | gpg --import \
  && gpg --batch --verify consul_${CONSUL_VERSION}_SHA256SUMS.sig consul_${CONSUL_VERSION}_SHA256SUMS \
  && grep consul_${CONSUL_VERSION}_linux_amd64.zip consul_${CONSUL_VERSION}_SHA256SUMS | sha256sum -c \
  && unzip -d usr/local/bin consul_${CONSUL_VERSION}_linux_amd64.zip \
  && rm consul_${CONSUL_VERSION}_linux_amd64.zip \
  && rm consul_${CONSUL_VERSION}_SHA256SUMS \
  && rm consul_${CONSUL_VERSION}_SHA256SUMS.sig \
  && chmod +x usr/local/bin/consul \
  && gpg --batch --verify consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS.sig consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS \
  && grep consul-template_${CONSULTEMPLATE_VERSION}_linux_amd64.zip consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS | sha256sum -c \
  && unzip -d usr/local/bin consul-template_${CONSULTEMPLATE_VERSION}_linux_amd64.zip \
  && rm consul-template_${CONSULTEMPLATE_VERSION}_linux_amd64.zip \
  && rm consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS \
  && rm consul-template_${CONSULTEMPLATE_VERSION}_SHA256SUMS.sig \
  && chmod +x usr/local/bin/consul-template

# S6 entrypoint, service definitions, healthcheck probe
COPY s6-services /etc/services.d/
COPY entrypoint /etc/cont-init.d/
COPY probe.sh initlog.sh /

# Override the exit script by ours to fix --pid=host operations
COPY init-stage3 /etc/s6/init/init-stage3

# Prepare for running without root
# - Create a dd-agent:root user and give it permissions on relevant folders
# - Remove the /var/run -> /run symlink and create a legit /var/run folder
# as some docker versions re-create /run from zero at container start
RUN adduser --system --no-create-home --disabled-password --ingroup root dd-agent \
 && rm -rf /var/run && mkdir -p /var/run/s6 \
 && chown -R dd-agent:root /etc/datadog-agent/ /etc/s6/ /var/run/s6/ /var/log/datadog/ \
 && chmod g+r,g+w,g+X -R /etc/datadog-agent/ /etc/s6/ /var/run/s6/ /var/log/datadog/ \
 && chmod 755 /probe.sh /initlog.sh

# Expose DogStatsD and trace-agent ports
EXPOSE 8125/udp 8126/tcp

HEALTHCHECK --interval=2m --timeout=5s --retries=2 \
  CMD ["/probe.sh"]

CMD ["/init"]
