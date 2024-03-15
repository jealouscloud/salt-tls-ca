{#
This is reusable state module.
Its implementation is actually in _orch/tls/ca.sls

If you want to trust the cert requested, 
then make sure your top file also includes tls.user

Usage (pillar)

tls:
  custom:
    mycert:
      ca_server: ca_minion_id
      ca_name: salt
      alt_name:
        - DNS: mycert.example.com
    another.cert: {}
#}

{% for key, value in salt.pillar.get("tls:custom", {}).items() %}
{% set cert_name = key %}
{% set alt_name = value.get("alt_name", none) %}
{% set ca_server = value.get("ca_server", salt.pillar.get("ca_server", "master")) %}
{% set ca_name = value.get("ca_name", salt.pillar.get("ca_name", "salt")) %}
{% set crt_path = "/etc/pki/" + cert_name + ".crt" %}

Valid certificate that does not expire:
  tls.valid_certificate:
    - name: {{ crt_path }}
    - days: 30

request certificate {{ cert_name }} from CA:
  event.send:
    - name: tls/request
    - data:
        ca_server: {{ ca_server }}
        ca_name: {{ ca_name }}
        cn: {{ cert_name }}
        alt_name: {{ alt_name|json }}
        dest_path: /etc/pki/
    - onfail:
      - tls: Valid certificate that does not expire

{% endfor %}
