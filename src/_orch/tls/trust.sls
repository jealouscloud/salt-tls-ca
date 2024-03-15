
{% set caller = salt.pillar.get('caller') %}
{% set ca_server = salt.pillar.get('ca_server') %}
{# todo: validate ca_server? idk #}
{% set ca_name = salt.pillar.get('ca_name') %}
{# can be minion id or a random caller supllied arg #}
{% set request_id = salt.pillar.get("request_id", caller) %}

# get the tls cert from the ca_server
Trust TLS cert from ca server:
  salt.runner:
    - name: datashare.use
      omit_ret: False
    - src:
        id: {{ ca_server }}
        cmd: file.read
        kwargs:
          path: /etc/pki/{{ ca_name }}/{{ ca_name }}_ca_cert.crt
    - target:
        id: {{ caller }}
        cmd: state.apply
        kwargs:
          mods:
            - ubuntu.tls.import
          pillar:
            cert_name: {{ ca_name }}
            cert_value: __DATA__
          queue: true

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
      - Trust TLS cert from ca server