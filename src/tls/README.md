# tls
Orchestrator driven TLS authority

## authority
State implementation of a certificate authority which can be orchestrated by salt

pillar
```yaml
tls:
  ca:
    salt:
      days: 365
```

## user
User functions for TLS.

pillar
```yaml
tls:
  custom: # tls.signed-certificate
    # cert_name : options
    kolla-registry.host: 
      ca_server: kolla-foundry
      ca_name: salt

  trust: # tls.user
    # minion_id : cert_name
    kolla-foundry: salt

```

## See also
* _orch/tls
* _reactor/tls