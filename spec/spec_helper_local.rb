# frozen_string_literal: true

require 'puppetlabs_spec_helper/module_spec_helper'

shared_examples 'fail' do
  it 'fails' do
    expect { subject.call }.to raise_error(%r{#{regex}})
  end
end
