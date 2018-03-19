#!/bin/bash
# Get all of the datadog configuration files.
export TOOLS_PREFIX=/usr/local/bin
export INTEGRATION_DIR=/etc/datadog-agent/conf.d
if [[ ${CONSUL_PREFIX} && ${ENABLE_INTEGRATIONS} ]]; then
  [[ ${CONSUL_DC} ]] && CONSUL_KV_DC="-datacenter=${CONSUL_DC}" || CONSUL_KV_DC=""
  [[ ${CONSUL_ADDR_FROM_AWS_META} && $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4) ]] \
  && export CONSUL_HTTP_ADDR=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4):8500
  if ${TOOLS_PREFIX}/consul kv get ${CONSUL_KV_DC} -keys "${CONSUL_PREFIX}"/integrations/ &>/dev/null; then
    for integration in $(${TOOLS_PREFIX}/consul kv get -keys "${CONSUL_PREFIX}"/integrations/); do
      THIS_INTEGRATION=$(echo "${integration}" | awk -F '/' '{print $NF}')
      if [[ ! -z "${THIS_INTEGRATION}" ]]; then
        if [[ ${ENABLE_INTEGRATIONS} == *"${THIS_INTEGRATION}"* ]]; then
        ## TODO: Update to new structure integration.d/integration.yaml
            ${TOOLS_PREFIX}/consul kv get ${CONSUL_KV_DC} "${integration}" > "${INTEGRATION_DIR}"/"${THIS_INTEGRATION}".yaml
            ${TOOLS_PREFIX}/consul-template -template "${INTEGRATION_DIR}"/"${THIS_INTEGRATION}".yaml:"${INTEGRATION_DIR}"/"${THIS_INTEGRATION}".yaml -once
        fi
      fi
    done
  fi
fi

# Enable logs
if [[ $DD_ENABLE_LOGS ]]; then
  echo -e "\n# Logs\nlog_enabled: true" | tee -a /etc/datadog-agent/datadog.yaml
fi
