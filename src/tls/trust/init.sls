{% set os = salt.grains.get("osfullname") %}
include:
{%- if os == "Ubuntu" %}
    - .ubuntu
{%- elif os == "AlmaLinux" %}
    - .alma
{%- else %}
{{ raise('tls.trust does not know how to update certificate store for this OS') }}
{%- endif %}
