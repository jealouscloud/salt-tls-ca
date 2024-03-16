{% set cert_name = salt.pillar.get("cert_name") %}
{% set crt_path = "/usr/local/share/ca-certificates/" + cert_name + "_ca.crt" %}

Ensure the CA trust bundle exists:
  file.directory:
    - name: /usr/local/share/ca-certificates

Ensure cert is in ca-certificates directory:
  file.managed:
    - source: /etc/pki/{{ cert_name }}.crt
    - name: {{ crt_path }}

Update CA certificates:
  cmd.run:
    - name: update-ca-certificates
    - onchanges:
      - Ensure cert is in ca-certificates directory

Log that we now trust the CA:
  grains.present:
    - name: 'tls:trusted:{{ cert_name }}'
    - value: True
    - require:
      - Ensure cert is in ca-certificates directory
      - Update CA certificates

