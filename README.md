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

Example that tells puppet to leave any rule in `INPUT:filter:IPv4` that has the string `Keep this`
```
profile_firewall::ignores:
  INPUT:filter:IPv4: "Keep this"
```

Example for ignoring Docker Rule Chains (note you also need to add an ignore for any DOCKER virtual interfaces it created, since not all those rules will have the string docker or DOCKER in them)
```
profile_firewall::ignores:
  INPUT:filter:IPv4: ["docker", "DOCKER"]
  OUTPUT:filter:IPv4: ["docker", "DOCKER"]
  FORWARD:filter:IPv4: ["docker", "DOCKER"]
  DOCKER:filter:IPv4: "*"
  DOCKER:nat:IPv4: "*"
```

After setting up `profile_firewall::ignores`, you also need to set `profile_firewall::purge_all: false` since these options are mutually exclusive.
By default `profile_firewall::purge_all` is set to true, the side effect of setting this to false is summarized in the table below:
||`purge_all: true`|`purge_all: false`|
| --- | --- | --- |
| Remove unmanaged rule from managed chain | Yes | Yes |
| Remove unmanaged rule from unmanaged chain | Yes | No |
| Remove unmanaged chain | Yes\* | No |

\* If your system has unmanaged firewall rules in an unmanaged firewallchain, the first time puppet runs it will only removed the unmanaged rules and an error `CHAIN_USER_DEL failed (Device or resource busy): chain CHAIN_NAME_HERE` will be logged. When puppet agent runs a second time it will then remove the empty chain

## Dependencies

- [puppetlabs/firewall](https://forge.puppet.com/modules/puppetlabs/firewall)

## Reference

### class profile_firewall (
-  Hash $ignores,
-  Hash $inbuilt_chains,
-  Hash $post,
-  Hash $pre,
-  Boolean $purge_all,
-  Hash $rules,

See: [REFERENCE](REFERENCE.md)

