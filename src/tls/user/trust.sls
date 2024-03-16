{% for ca_server, ca_name in salt.pillar.get("tls:trust", {}).items() %}

{{ ca_name }} is a certificate that does not expire:
  tls.valid_certificate:
    - name: /etc/pki/{{ ca_name }}.crt
    - days: 30
    
# Only request to trust CA cert if we havent already
{% if not salt.grains.get("tls:trusted:" + ca_server, false) %}
Request CA trust update from {{ ca_server }} for {{ ca_name }}:
  event.send:
    - name: tls/trust # handle this by sending it to tls.trust orchestrator
    - data:
        ca_server: {{ ca_server }}
        ca_name: {{ ca_name }}
    - onerror:
        - {{ ca_name }} is a certificate that does not expire
{% endif %}

{% endfor %}
