require 'spec_helper'
describe 'authorization' do

  context 'with defaults for all parameters' do
    it { should contain_class('authorization') }
  end
end
