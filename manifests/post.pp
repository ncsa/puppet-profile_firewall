# @summary Default firewall post rule, Drop all
#
# @example
#   include profile_firewall::post
class profile_firewall::post {

    firewall { '999 drop all':
        proto  => 'all',
        action => 'drop',
        before => undef,
    }

}
