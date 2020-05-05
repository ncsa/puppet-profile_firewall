# @summary Basic firewall setup
#
# @example
#   include profile_firewall::pre
class profile_firewall::pre {

    Firewall {
        require => undef,
    }

    firewall { '000 accept all icmp':
        proto  => 'icmp',
        action => 'accept',
    }

    firewall { '001 accept all to lo':
        proto   => 'all',
        iniface => 'lo',
        action  => 'accept',
    }

    firewall { '002 accept related established':
        proto  => 'all',
        state  => ['RELATED', 'ESTABLISHED'],
        action => 'accept',
    }

}
