
{% set caller = salt.pillar.get('caller') %}
{% set ca_server = salt.pillar.get('ca_server') %}
{# todo: validate ca_server? idk #}
{% set ca_name = salt.pillar.get('ca_name') %}
{# can be minion id or a random caller supllied arg #}
{% set request_id = salt.pillar.get("request_id", caller) %}

# get the tls cert from the ca_server
Trust TLS cert from ca server:
  salt.runner:
    - name: state.orchestrate
    - mods: .xfer
    - pillar:
        src:
          id: {{ ca_name }}
          path: /etc/pki/{{ ca_name }}/{{ ca_name }}_ca_cert.crt
        target:
          id: {{ caller }}
          path: /etc/pki/{{ ca_name }}.crt

Import certificate to the system trust store:
  salt.state:
    - tgt: {{ caller }}
    - queue: true
    - sls:
      - tls.trust
    - require:
      - Wait for signing to complete

Notify master we were successful:
  salt.function:
    - name: event.send
    - tgt: {{ caller | yaml_dquote }}
    - kwarg:
        tag: orch/return/tls.trust/{{ request_id }}
        data:
          result: "success"
          comment: "TLS cert imported"
    - require:
      - Import certificate to the system trust store
      - Trust TLS cert from ca server