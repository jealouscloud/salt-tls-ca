Ensure PKI directories exist:
  file.directory:
    - name: /etc/pki/issued_certs
    - makedirs: true

{% for cert_name, args in salt.pillar.get("tls:ca", {}).items() %}

Generate CA certificate and key:
  module.run:
    - tls.create_ca:
      - ca_name: {{ cert_name }}
      - CN: {{ cert_name }}
      - bits: 4096
      - days: {{ args.get("days", 365) }}
      - replace: false
    - require:
      - file: /etc/pki/issued_certs

{% endfor %}