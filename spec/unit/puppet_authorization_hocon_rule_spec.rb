require 'spec_helper'

describe Puppet::Type.type(:puppet_authorization_hocon_rule) do
  let(:resource) {
    Puppet::Type.type(:puppet_authorization_hocon_rule).new(
      :name  => 'auth rule',
      :path  => '/tmp/auth.conf',
      :value => {},
    )
  }

  it 'is ensurable' do
    resource[:ensure] = :present
    expect(resource[:ensure]).to be(:present)
    resource[:ensure] = :absent
    expect(resource[:ensure]).to be(:absent)
  end

  it 'raises an error if an invalid ensure value is passed' do
    expect { resource[:ensure] = 'file' }.to raise_error \
      Puppet::Error, /Invalid value "file"/
  end

  it 'accepts valid hash values' do
    hash = { 'key' => 'value' }
    resource[:value] = hash
    expect(resource[:value]).to eq([hash])
  end

  it 'raises an error with invalid hash values' do
    expect { resource[:value] = 4 }.to raise_error \
      Puppet::Error, /Value must be a hash/
  end

  it 'raises an error with invalid path values' do
    expect { resource[:path] = "not/absolute/path" }.to raise_error \
      Puppet::Error, /File paths must be fully qualified/
  end
end
