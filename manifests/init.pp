# @summary Initial firewall configuration
#
# @example
#   include profile_firewall
class profile_firewall {

  include ::firewall
  include ::profile_firewall::pre
  include ::profile_firewall::post

  resources { 'firewall':
    purge =>  true,
  }

  resources { 'firewallchain':
    purge =>  true,
  }

  firewallchain { 'INPUT:filter:IPv4':
    ensure => present,
    policy => drop,
    before => undef,
  }

  Firewall {
    require =>  Class['profile_firewall::pre'],
    before  => Class['profile_firewall::post'],
  }
}
