# frozen_string_literal: true

require 'spec_helper'
describe 'puppet_authorization' do
  subject(:catalog) { -> { catalogue } }

  let(:facts) do
    { concat_basedir: '/dne' }
  end
  let(:title) do
    '/tmp/foo'
  end

  context 'with defaults' do
    it {
      expect(catalog).to contain_concat(title).with({
                                                      path: title,
                                                      replace: false,
                                                    })
    }

    it {
      expect(catalog).to contain_concat__fragment("00_header_#{title}").with({
                                                                               target: title,
                                                                             }).with_content(%r{authorization: \{\n  rules: \[\]\n})
    }

    it {
      expect(catalog).to contain_concat__fragment("99_footer_#{title}").with({
                                                                               target: title,
                                                                             }).with_content(%r{\}\n})
    }

    it { # rubocop:disable RSpec/ExampleLength
      expect(catalog).to contain_hocon_setting("authorization.version.#{title}")
        .that_requires("Concat[#{title}]").with({
                                                  path: title,
                                                  setting: 'authorization.version',
                                                  value: 1,
                                                })
    }

    it { # rubocop:disable RSpec/ExampleLength
      expect(catalog).to contain_hocon_setting(
        "authorization.allow-header-cert-info.#{title}",
      )
        .that_requires("Concat[#{title}]").with({
                                                  path: title,
                                                  setting: 'authorization.allow-header-cert-info',
                                                  value: false,
                                                })
    }
  end

  context 'with non-default parameters' do
    let(:params) do
      {
        version: 2,
        allow_header_cert_info: true,
        replace: true,
        path: '/tmp/foo',
      }
    end

    it {
      expect(catalog).to contain_concat(title).with({
                                                      path: '/tmp/foo',
                                                      replace: true,
                                                    })
    }

    it {
      expect(catalog).to contain_concat__fragment("00_header_#{title}").with({
                                                                               target: title,
                                                                             }).with_content(%r{authorization: \{\n  rules: \[\]\n})
    }

    it {
      expect(catalog).to contain_concat__fragment("99_footer_#{title}").with({
                                                                               target: title,
                                                                             }).with_content(%r{\}\n})
    }

    it { # rubocop:disable RSpec/ExampleLength
      expect(catalog).to contain_hocon_setting("authorization.version.#{title}")
        .that_requires("Concat[#{title}]").with({
                                                  path: '/tmp/foo',
                                                  setting: 'authorization.version',
                                                  value: 2,
                                                })
    }

    it { # rubocop:disable RSpec/ExampleLength
      expect(catalog).to contain_hocon_setting(
        "authorization.allow-header-cert-info.#{title}",
      )
        .that_requires("Concat[#{title}]").with({
                                                  path: '/tmp/foo',
                                                  setting: 'authorization.allow-header-cert-info',
                                                  value: true,
                                                })
    }
  end

  describe 'failures' do
    context 'with a relative path' do
      it_behaves_like 'fail' do
        let(:params) { { path: 'foo' } }
        let(:regex) { 'path' }
      end
    end

    context 'with a non-string path' do
      it_behaves_like 'fail' do
        let(:params) { { path: 2 } }
        let(:regex) { 'path' }
      end
    end

    context 'with invalid allow_header_cert_info' do
      it_behaves_like 'fail' do
        let(:params) { { allow_header_cert_info: 'foo' } }
        let(:regex) { 'allow_header_cert_info' }
      end
    end

    context 'with invalid replace' do
      it_behaves_like 'fail' do
        let(:params) { { replace: 'foo' } }
        let(:regex) { 'replace' }
      end
    end
  end
end
