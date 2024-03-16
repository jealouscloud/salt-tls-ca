{% set ca_server =  salt.pillar.get('ca_server') %} # minion id
{% set ca_name = salt.pillar.get('ca_name') %} # name of cert on the ca server

{% set cn =  salt.pillar.get('cn') %} # cert name
{% set alt_name =  salt.pillar.get('alt_name') %}
{% set caller = salt.pillar.get('caller') %}
{% set dest_path = salt.pillar.get('dest_path').rstrip("/") %}
{% set request_id = salt.pillar.get("request_id", caller) %}

Create CSR:
  salt.function:
    - name: tls.create_csr
    - tgt: {{ ca_server | yaml_dquote }}
    - arg:
      - {{ ca_name | yaml_dquote }}
    - kwarg:
        CN: {{ cn  | yaml_dquote}}
        cert_type: server
        bits: 4096
  {% if alt_name %}
        subjectAltName: {{ alt_name | yaml_dquote }}
  {% endif %}
        replace: false # we can enable this if we program in revokation

Sign with CA certificate and key:
  salt.function:
    - name: tls.create_ca_signed_cert
    - tgt: {{ ca_server | yaml_dquote }}
    - arg:
      - {{ ca_name | yaml_dquote }}
    - kwarg:
        CN: {{ cn | yaml_dquote}}
        days: 365
        replace: false
    - require: 
      - Create CSR

{% set cert_path = "/etc/pki/" + ca_name + "/certs/" + cn + ".crt" %}
{% set key_path = "/etc/pki/" + ca_name + "/certs/" + cn + ".key" %}
{% set titles = [] %}
{% for title, src_path, write_path in [ 
  ("certificate", cert_path, dest_path + "/" + cn + ".crt"), 
  ("private key", key_path, dest_path + "/" + cn + ".key")] 
%}
{% set title = "Write " + title + " to " + write_path %}
{% do titles.append(title) %}
{{ title }}:
  salt.runner:
    - name: state.orchestrate
    - mods: _orch.tls.xfer
    - pillar:
        src:
          id: {{ ca_server | yaml_dquote }}
          path: {{ src_path | yaml_dquote }}
        target:
          id: {{ caller }}
          path: {{ write_path | yaml_dquote}}
    - require:
      - Sign with CA certificate and key
{% set _ = titles.append(title) %}
{% endfor %}


Notify master of success:
  salt.function:
    - name: event.send
    - tgt: {{ caller | yaml_dquote }}
    - kwarg:
        tag: orch/return/tls.ca/{{ request_id }}
        data:
          result: "success"
          comment: "Received TLS certificate and key"
    - require:
{%- for title in titles %}
        - {{ title }}
{% endfor -%}
