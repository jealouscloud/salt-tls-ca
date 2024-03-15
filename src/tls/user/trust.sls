{% for ca_server, ca_name in salt.pillar.get("tls:trust", {}).items() %}

# Only request to trust CA cert if we havent already
{% if not salt.grains.get("tls:trusted:" + ca_server, false) %}
Request CA trust update from {{ ca_server }}:
  event.send:
    - name: tls/trust
    - data:
        ca_server: {{ ca_server }}
        ca_name: {{ ca_name }}
{% endif %}

{% endfor %}
