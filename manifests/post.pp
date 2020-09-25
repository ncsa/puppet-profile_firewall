# @summary Default firewall post rule, Drop all
#
# Default firewall post rule, Drop all
#
# Included by profile_firewall
class profile_firewall::post {

  firewall { '999 drop all':
    proto  => 'all',
    action => 'drop',
    before => undef,
  }

}
