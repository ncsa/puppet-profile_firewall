# @summary Initial firewall configuration
#
# @param manage_builtin_chains
#   If true (default), then pre-define built-in iptables chains.
#   Set to false if another profile will manage built-in chains (e.g.
#   profile_docker).
#   See also: https://forge.puppet.com/puppetlabs/firewall
#
# @example
#   include profile_firewall
class profile_firewall (
  Boolean $manage_builtin_chains,
) {

  # DON'T EVER DO THIS ---
  # SEE: https://tickets.puppetlabs.com/browse/MODULES-5171
  # specifically..."using the resources resource will just purge 
  #                 all resources independent of the ignore statement"
  # --- YOU HAVE BEEN WARNED
  # resources { 'firewall':
  #   purge =>  true,
  # }
  # resources { 'firewallchain':
  #   purge =>  true,
  # }

  Firewall {
    require =>  Class['profile_firewall::pre'],
    before  => Class['profile_firewall::post'],
  }

  class { 'firewall':
    ebtables_manage => true,
  }

  include ::profile_firewall::pre
  include ::profile_firewall::post

  #  notify { "manage_builtin_chains is ${$manage_builtin_chains}" : }
  if $manage_builtin_chains {
    # notify { 'about to include ::profile_firewall::builtin_chains' : }
    include ::profile_firewall::builtin_chains
  }

}
