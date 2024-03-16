#!py
"""
Salt orchestrator for shuffling tls data between minions
"""

def remote_cmd(minion_id, fun, arg, kwarg):
    """
    Return the pillar data for a minion
    """
    result = __salt__["saltutil.cmd"](tgt=minion_id, fun=fun, arg=arg, kwarg=kwarg)
    ret = result[minion_id]
    retcode = ret['retcode']
    if retcode != 0:
        raise Exception(f"Failed to execute {fun} on {minion_id}")

    return ret['ret']

def run():
    source = __salt__["pillar.get"]("src")
    src = source.get("id")
    src_path = source.get("path")

    # TODO: check for pillar key "remote_ca"

    target = __salt__["pillar.get"]("target")
    tgt = target.get("id")
    tgt_path = target.get("path")

    config = {}

    remote_cert = remote_cmd(src, "file.read", [], {"path": src_path})
    config["Write PEM to file"] = {
        "salt.function": [
            {"name": "x509.write_pem"},
            {"tgt": tgt},
            {"kwarg": {"path": tgt_path, "text": remote_cert}},
        ]
    }
    return config
