# @summary Initial firewall configuration
#
# @param ignores
#   Lists of regex's telling Puppet to NOT remove matching rules, even if the
#   rules were not added by Puppet.
#
#   Keys must be in "CHAIN:TABLE:PROTOCOL" format.
#   Values must be an Array of strings in Ruby regex format.
#   See README for some basic examples, or the following for more details:
#   https://forge.puppet.com/puppetlabs/firewall/reference#firewallchain
#
# @param ignore_chain_prefixes
#   List of strings.
#   All existing iptables chains will be collected by a custom fact.
#   If any chain name starts with one of these prefixes, that chain, and
#   any rules in that chain, will be ignored by Puppet.
#
# @param pre
#   Exceptions to start the firewall rules
#   Keys must begin with a 3-digit numer followed by a comment.
#   The 3-digit number indicates firewall rule order, lower numbered rules are
#   added before higher numbers.
#   See README for some basic examples, or the following for more details:
#   https://forge.puppet.com/puppetlabs/firewall/readme#beginning-with-firewall
#
# @param post
#   Exceptions to end the firewall rules.
#   Keys must begin with a 3-digit numer followed by a comment.
#   The 3-digit number indicates firewall rule order, lower numbered rules are
#   added before higher numbers.
#   See README for some basic examples, or the following for more details:
#   https://forge.puppet.com/puppetlabs/firewall/readme#beginning-with-firewall
#
# @param rules
#   Generic firewall rules.
#   Keys must begin with a 3-digit numer followed by a comment.
#   The 3-digit number indicates firewall rule order, lower numbered rules are
#   added before higher numbers.
#   See README for some basic examples, or the following for more details:
#   https://forge.puppet.com/puppetlabs/firewall/readme#beginning-with-firewall
#
# @param inbuilt_chains
#   Default Linux chains. Module defaults should be sufficient.
#   Keys must be in "CHAIN:TABLE:PROTOCOL" format.
#   Values must be Hash of valid puppetlabs::firewallchain parameters
#
# @example
#   include profile_firewall
class profile_firewall (
  Hash    $ignores,
  Array   $ignore_chain_prefixes,
  Hash    $inbuilt_chains,
  Hash    $post,
  Hash    $pre,
  Hash    $rules,
) {

  class { 'firewall':
    ebtables_manage => true,
  }

  # Check if we are using $ignores to decide if we should purge all unmanaged rules
  # SEE: https://tickets.puppetlabs.com/browse/MODULES-5171
  # specifically..."using the resources resource will just purge
  #                 all resources independent of the ignore statement"
  if empty($ignores) and empty($ignore_chain_prefixes) {
    # Not using ignores, ok to purge all
    resources { 'firewall':
      purge =>  true,
    }
    resources { 'firewallchain':
      purge =>  true,
    }
  } else {

    # Ignore any non-standard chains matching specified prefixes
    $ignore_chain_prefixes.each | $pfx | {
      $facts['custom_firewallchains'].each | $chain, $data | {
        if $chain.stdlib::start_with( $pfx ) {
          # notify { "IGNORE CHAIN ${chain}:${data['table']}:${data['protocol']}": }
          firewallchain { "${chain}:${data['table']}:${data['protocol']}" :
            purge => false,
          }
        }
      }
    }

    # CREATE DEFAULT CHAINS
    $default_params = {
      ensure => present,
      purge  => true,
    }
    $inbuilt_chains.each | $chain_name, $inbuilt_params | {

      # Combine params from hiera with chain defaults
      $custom_params = $inbuilt_params ? {
        undef   => $default_params,
        default => $default_params + $inbuilt_params,
      }

      # Add any ignores for this chain
      $chain_params = $ignores[$chain_name] ? {
        undef   => $custom_params,
        default => $custom_params + { ignore => $ignores[$chain_name] },
      }

      # Debugging
      # $chain_params.each | $key, $val | {
      #   notify {"FWchain ${chain_name} ${key} ${val}" :}
      # }

      firewallchain { $chain_name :
          * => $chain_params,
      }

    }
  }

  create_resources( firewall, $pre )
  if ( $rules ) {
    create_resources( firewall, $rules )
  }
  create_resources( firewall, $post )

}
