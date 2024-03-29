{% set cert_name = salt.pillar.get("cert_name") %}
{% set crt_path = "/etc/pki/ca-trust/source/anchors/" + cert_name + "_ca.crt" %}

Ensure the CA trust bundle exists:
  file.directory:
    - name: /etc/pki/ca-trust/source/anchors/

Import CA Certificate:
  x509.pem_managed:
    - name: {{ crt_path | yaml_encode }}
    - text: {{ salt.pillar.get("cert_value") | yaml_encode}}

Update CA certificates:
  cmd.run:
    - name: update-ca-trust
    - onchanges:
      - x509: Import CA Certificate

Log that we now trust the CA:
  grains.present:
    - name: 'tls:trusted:{{ cert_name }}'
    - value: True
    - require:
      - Import CA Certificate
      - Update CA certificates