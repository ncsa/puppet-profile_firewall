# frozen_string_literal: true

Facter.add(:custom_firewallchains) do
  # https://puppet.com/docs/puppet/latest/fact_overview.html
  setcode do
    data = {}
    [ 'nat', 'filter' ].each do |table|
      lines = Facter::Core::Execution.execute("/usr/sbin/iptables -t #{table} -S")
      chain_names = lines.scan('/^-N (.+)$/').flatten
      chain_names.each do |name|
        data[name] = { 'chain' => name, 'table' => table, 'protocol' => 'IPv4' }
      end
    end
    data
  end
end
