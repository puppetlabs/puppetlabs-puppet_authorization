require 'spec_helper'

provider_class = Puppet::Type.type(:puppet_authorization_hocon_rule).provider(:ruby)

describe provider_class do
  include PuppetlabsSpec::Files

  context 'rules array' do
    let(:tmpfile) { tmpfilename('puppet_authorization_rule_test.conf') }

    before :each do
      File.open(tmpfile, 'w') do |f|
        f.write(<<-EOS)
authorization: {
  version: 1
  rules: [
    {
      match-request: {
          path: /foo
          type: path
      }
      allow: foo
      name: foo-rule
      sort-order: 666
    }
  ]
}
EOS
      end
    end

    it 'should add a new rule to the array' do
      resource = Puppet::Type::Puppet_authorization_hocon_rule.new(
        :title => 'bar rule',
        :path  => tmpfile,
        :value => {
          'match-request' => {
            'path' => '/bar',
            'type' => 'path'
          },
          'allow'      => 'bar',
          'name'       => 'bar-rule',
          'sort-order' => 777 })

      provider = provider_class.new(resource)
      expect(provider.exists?).to be false
      provider.create
      expect(File.read(tmpfile)).to eq(<<-EOS)
authorization: {
  version: 1
  rules: [
      {
          "allow" : "foo",
          "match-request" : {
              "path" : "/foo",
              "type" : "path"
          },
          "name" : "foo-rule",
          "sort-order" : 666
      }
  ,
      {
          "allow" : "bar",
          "match-request" : {
              "path" : "/bar",
              "type" : "path"
          },
          "name" : "bar-rule",
          "sort-order" : 777
      }
  
  ]
}
EOS
    end

    it 'should remove a rule from the array' do
      resource = Puppet::Type::Puppet_authorization_hocon_rule.new(
        :title  => 'foo rule',
        :path   => tmpfile,
        :ensure => 'absent',
        :value  => {
          'name' => 'foo-rule',
          })

      provider = provider_class.new(resource)
      expect(provider.exists?).to be true
      provider.destroy
      expect(File.read(tmpfile)).to eq(<<-EOS)
authorization: {
  version: 1
  rules: []
}
EOS
    end
  end
end
