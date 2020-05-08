# @summary Pre-define built-in chains to puppet
#
# Pre-define built-in chains to puppet
#
# Prevent puppet from trying to remove builtin chains,
# which will fail and cause unneccesary warnings.
#
# Included by profile_firewall if $profile_firewall::manage_builtin_chains is true.
#
# @param tables
#   Default (built-in) table names and a
#   list of chains and versions for each.
class profile_firewall::builtin_chains (
  Hash[ String[1], Hash[ String[1], Array, 1 ], 1 ] $tables,
) {

  $tables.each | $table, $t_data | {
    $t_data[ 'chains' ].each | $chain | {
      $t_data[ 'protocols' ].each | $protocol | {
        firewallchain { "${chain}:${table}:${protocol}" :
          ensure => present,
        }
      }
    }
  }

}
# {chain}:{table}:{protocol}
