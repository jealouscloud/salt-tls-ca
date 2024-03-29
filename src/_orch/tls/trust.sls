
{% set caller = salt.pillar.get('caller') %}
{% set ca_server = salt.pillar.get('ca_server') %}
{# todo: validate ca_server? idk #}
{% set ca_name = salt.pillar.get('ca_name') %}
{# can be minion id or a random caller supllied arg #}
{% set request_id = salt.pillar.get("request_id", caller) %}

# get the tls cert from the ca_server
Make target directory:
  salt.function:
    - name: state.single
    - tgt: {{ caller | yaml_dquote }}
    - kwarg:
        fun: file.directory
        name: /etc/pki/

Trust TLS cert from ca server:
  salt.runner:
    - name: state.orchestrate
    - mods: _orch.tls.xfer
    - pillar:
        src:
          id: {{ ca_server }}
          path: /etc/pki/{{ ca_name }}/{{ ca_name }}_ca_cert.crt
        target:
          id: {{ caller }}
          path: /etc/pki/{{ ca_name }}.crt
    - require:
      - Make target directory

Import certificate to the system trust store:
  salt.state:
    - tgt: {{ caller }}
    - queue: true
    - sls:
      - tls.trust
    - pillar:
        cert_name: {{ ca_name }}
    - require:
      - Trust TLS cert from ca server

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