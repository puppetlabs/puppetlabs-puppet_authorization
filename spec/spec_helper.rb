require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.add_setting :confdir, :default => '/etc/puppetlabs/puppet'
end

shared_examples 'fail' do
  it 'fails' do
    expect { subject.call }.to raise_error(/#{regex}/)
  end
end
