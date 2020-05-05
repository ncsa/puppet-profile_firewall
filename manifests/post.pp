# @summary Default firewall post rule, Drop all
#
# @example
#   include profile_firewall::post
class profile_firewall::post {

    # firewall { '999 drop all':
    #     proto  => 'all',
    #     action => 'drop',
    #     before => undef,
    # }

    firewallchain { 'INPUT:filter:IPv4':
        ensure =>  present,
        policy =>  drop,
        before =>  undef,
    }

}
