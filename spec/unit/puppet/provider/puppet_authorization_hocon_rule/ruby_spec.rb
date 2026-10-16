# frozen_string_literal: true

require 'spec_helper'

provider_class = Puppet::Type.type(:puppet_authorization_hocon_rule).provider(:ruby)

describe provider_class do
  include PuppetlabsSpec::Files

  let(:tmpfile) { tmpfilename('puppet_authorization_rule_test.conf') }

  context 'with rules already in the target file as a non-empty array' do
    before :each do
      File.write(tmpfile, <<~HOCON)
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
      HOCON
    end

    it 'adds a new rule to the array' do
      resource = Puppet::Type::Puppet_authorization_hocon_rule.new(
        title: 'bar rule',
        path: tmpfile,
        value: {
          'match-request' => {
            'path' => '/bar',
            'type' => 'path',
          },
          'allow' => 'bar',
          'name' => 'bar-rule',
          'sort-order' => 777,
        },
      )

      provider = provider_class.new(resource)
      expect(provider.exists?).to be false
      provider.create
      expect(File.read(tmpfile)).to eq(<<~HOCON)
        authorization: {
          version: 1
          rules: [
              {
                  "allow": "foo",
                  "match-request": {
                      "path": "/foo",
                      "type": "path"
                  },
                  "name": "foo-rule",
                  "sort-order": 666
              }
          ,
              {
                  "allow": "bar",
                  "match-request": {
                      "path": "/bar",
                      "type": "path"
                  },
                  "name": "bar-rule",
                  "sort-order": 777
              }
        #{'  '}
          ]
        }
      HOCON
    end

    it 'removes a rule from the array' do
      resource = Puppet::Type::Puppet_authorization_hocon_rule.new(
        title: 'foo rule',
        path: tmpfile,
        ensure: 'absent',
        value: {
          'name' => 'foo-rule',
        },
      )

      provider = provider_class.new(resource)
      expect(provider.exists?).to be true
      provider.destroy
      expect(File.read(tmpfile)).to eq(<<~HOCON)
        authorization: {
          version: 1
          rules: []
        }
      HOCON
    end
  end

  context 'without rules already in the target file' do
    it 'creates the rule setting as an array and add a rule to it' do
      resource = Puppet::Type::Puppet_authorization_hocon_rule.new(
        title: 'bar rule',
        path: tmpfile,
        value: {
          'match-request' => {
            'path' => '/bar',
            'type' => 'path',
          },
          'allow' => 'bar',
          'name' => 'bar-rule',
          'sort-order' => 777,
        },
      )

      provider = provider_class.new(resource)
      expect(provider.exists?).to be false
      provider.create
      expect(File.read(tmpfile)).to eq(<<~HOCON)
        authorization: {
          rules: [
              {
                  "allow": "bar",
                  "match-request": {
                      "path": "/bar",
                      "type": "path"
                  },
                  "name": "bar-rule",
                  "sort-order": 777
              }
        #{'  '}
          ]
        }
      HOCON
    end
  end

  context 'with rules in the target file that are not an array' do
    it 'rewrites the rules setting as an array and add a rule to it' do
      File.write(tmpfile, <<~HOCON)
        authorization: {
          version: 1
          rules: 42
        }
      HOCON

      resource = Puppet::Type::Puppet_authorization_hocon_rule.new(
        title: 'bar rule',
        path: tmpfile,
        value: {
          'match-request' => {
            'path' => '/bar',
            'type' => 'path',
          },
          'allow' => 'bar',
          'name' => 'bar-rule',
          'sort-order' => 777,
        },
      )

      provider = provider_class.new(resource)
      expect(provider.exists?).to be false
      provider.create
      expect(File.read(tmpfile)).to eq(<<~HOCON)
        authorization: {
          version: 1
          rules: [
              {
                  "allow": "bar",
                  "match-request": {
                      "path": "/bar",
                      "type": "path"
                  },
                  "name": "bar-rule",
                  "sort-order": 777
              }
        #{'  '}
          ]
        }
      HOCON
    end
  end
end
