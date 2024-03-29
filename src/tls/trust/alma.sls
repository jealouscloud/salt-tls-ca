{% set cert_name = salt.pillar.get("cert_name") %}
{% set crt_path = "/etc/pki/ca-trust/source/anchors/" + cert_name + "_ca.crt" %}

Ensure the CA trust bundle exists:
  file.directory:
    - name: /etc/pki/ca-trust/source/anchors/

Ensure cert is in trust anchors directory:
  file.managed:
    - source: /etc/pki/{{ cert_name }}.crt
    - name: {{ crt_path }}
    - require: 
      - Ensure the CA trust bundle exists

Update CA certificates:
  cmd.run:
    - name: update-ca-trust
    - onchanges:
      - Ensure cert is in trust anchors directory

Log that we now trust the CA:
  grains.present:
    - name: 'tls:trusted:{{ cert_name }}'
    - value: True
    - require:
      - Ensure cert is in trust anchors directory
      - Update CA certificates