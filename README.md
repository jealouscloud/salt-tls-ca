# salt-tls-ca
Saltstack certificate authority

### Requirements
Until salt 3009 you **must** do the following in your minion conf

```
features:
  x509_v2: true
```

### Description
**WIP** PRs welcome


I did not use the saltstack extension formula for this but you can integrate it by adding it as a gitfs remote
```
gitfs_remotes:
  - git@github.com:jealouscloud/salt-tls-ca.git:
    - base: main
    - root: src
```

You could create a reactor to automate using this

_reactor/tls/trust.sls
```
run tls orchestrator:
  runner.state.orchestrate:
    - args:
      - mods: _orch.tls.trust
      - pillar:
          caller: {{ data['id'] }}
          ca_server: {{ data['data']['ca_server'] | yaml_dquote }}
          ca_name: {{ data['data']['ca_name'] | yaml_dquote }}
```

Or one to create a certificate

_reactor/tls/request.sls
```
run tls orchestrator:
  runner.state.orchestrate:
    - args:
      - mods: _orch.tls.ca
      - pillar:
      {%- for key in ['ca_server', 'ca_name', 'cn', 'alt_name', 'dest_path'] %}
          {{ key }}: {{ data['data'][key] | json }}
      {% endfor %}
          caller: {{ data['id'] }}
```

## State usage
Include tls.authority as a CA
Include tls.user as a trustee

A signed certificate from the CA can be requested by firing tls.signed-certificate 
Note: You must have pillar tls:custom:hostname setup (you can check pillar.example)