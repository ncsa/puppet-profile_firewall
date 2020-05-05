# Baseline Firewall Configuration

Part of NCSA Common Puppet Profiles

## Usage
In Puppetfile:
```
mod 'ncsa/profile_firewall', branch: 'production', git: 'https://github.com/ncsa/puppet-profile_firewall'
```

## Reference
See: [REFERENCE](REFERENCE.md)

## Contributing
From the module root:
- Validate puppet code:
  - `pdk validate puppet`
- Validate yaml data:
  - `find . -type d | xargs -n1 yamllint`
- Update REFERENCE file:
  - `pdk bundle exec puppet strings generate --format markdown --out REFERENCE.md`
