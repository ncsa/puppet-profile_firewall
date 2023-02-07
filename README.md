# profile_firewall

[![pdk-validate](https://github.com/ncsa/puppet-profile_firewall/actions/workflows/pdk-validate.yml/badge.svg)](https://github.com/ncsa/puppet-profile_firewall/actions/workflows/pdk-validate.yml) [![yamllint](https://github.com/ncsa/puppet-profile_firewall/actions/workflows/yamllint.yml/badge.svg)](https://github.com/ncsa/puppet-profile_firewall/actions/workflows/yamllint.yml)

Provides a base for iptables firewall

By default this module will modify the firewall so that it will:
- Accept all icmp traffic from NCSA and Campus Nagios IP space
- Accept icmp echo from everywhere
- Accept all lo traffic
- Accept all Related,Established traffic
- Blocks everything else

Firewall rule changes required for a specific nodes/service function should be added within that module that manages the node/service. This module purpose is to provide a base.

## Usage

### Ignore a firewall rule

By deault, Puppet will delete any firewall rules that are not set by Puppet itself. Ideally you should add all rules to be managed by puppet, but this module does allow you to designate a firewall rule so that it is not deleted.

This is done by setting this value in hiera `profile_firewall::ignores`

Keys must be in "CHAIN:TABLE:PROTOCOL" format. Values must be an Array of strings in Ruby regex format.

:triangular_flag_on_post:
Example that tells puppet to leave any rule in `INPUT:filter:IPv4` that has the string `Keep this`
```
profile_firewall::ignores:
  INPUT:filter:IPv4: "Keep this"
```

:triangular_flag_on_post:
Example for ignoring Docker Rule Chains (note you also need to add an ignore for any DOCKER virtual interfaces it created, since not all those rules will have the string docker or DOCKER in them)
```
profile_firewall::ignores:
  INPUT:filter:IPv4: ["docker", "DOCKER"]
  OUTPUT:filter:IPv4: ["docker", "DOCKER"]
  FORWARD:filter:IPv4: ["docker", "DOCKER"]
  DOCKER:filter:IPv4: "*"
  DOCKER:nat:IPv4: "*"
```

:warning:
If your system has unmanaged firewall rules in an unmanaged firewallchain, the first time puppet runs it will only removed the unmanaged rules and an error `CHAIN_USER_DEL failed (Device or resource busy): chain CHAIN_NAME_HERE` will be logged. When puppet agent runs a second time it will then remove the empty chain. Use the `$ignore_chain_prefixes` parameter to prevent puppet removing "unmanaged" chains (see below).

### Ignore entire firewall chain(s)
Non-standard firewall chains can be ignored by specifying them as strings in an array to the `$ignore_chain_prefixes` parameter. As a convenience, if multiple chains (to be ignored) start with the same name, add just the common prefix.

:triangular_flag_on_post:
Example for ignoring Podman chains on RHEL8.
Podman creates some statically named chains, but also makes dynamically named chains for each container/pod deployed. Conveniently, all chain names start with `CNI-` so it's quite simple to instruct Puppet to ignore these chains entirely with the following YAML in hiera:
```
profile_firewall::ignore_chain_prefixes:
  - "CNI-"
profile_firewall::ignores:
  FORWARD:filter:IPv4:
    - "-j CNI-"
  PREROUTING:nat:IPv4:
    - "-j CNI-"
  OUTPUT:nat:IPv4:
    - "-j CNI-"
  POSTROUTING:nat:IPv4:
    - "-j CNI-"
```

## Dependencies

- [puppetlabs/firewall](https://forge.puppet.com/modules/puppetlabs/firewall)

## Reference

### class profile_firewall (
-  Hash    $ignores,
-  Array   $ignore_chain_prefixes,
-  Hash    $inbuilt_chains,
-  Hash    $post,
-  Hash    $pre,
-  Hash    $rules,

See also: [REFERENCE](REFERENCE.md)
