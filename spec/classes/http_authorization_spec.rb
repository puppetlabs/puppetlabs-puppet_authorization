require 'spec_helper'
describe 'http_authorization' do
  let(:facts) do
    { :concat_basedir => '/dne' }
  end

  before do
    Puppet.settings[:confdir] = '/etc/puppetlabs/puppet'
  end

  context 'defaults' do
    it { is_expected.to contain_concat('server-auth.conf').with({
      :path    => "#{Puppet.settings[:confdir]}/auth.conf",
      :replace => false,
    })}

    it { is_expected.to contain_concat__fragment('00_header').with({
      :target => 'server-auth.conf',
    }).with_content(/authorization: \{\n  rules: \[\]\n/)}

    it { is_expected.to contain_concat__fragment('99_footer').with({
      :target => 'server-auth.conf',
    }).with_content(/\}\n/)}

    it { is_expected.to contain_hocon_setting('authorization.version').that_requires('Concat[server-auth.conf]').with({
      :path    => "#{Puppet.settings[:confdir]}/auth.conf",
      :setting => 'authorization.version',
      :value   => 1,
    })}

    it { is_expected.to contain_hocon_setting('authorization.allow-header-cert-info').that_requires('Concat[server-auth.conf]').with({
      :path    => "#{Puppet.settings[:confdir]}/auth.conf",
      :setting => 'authorization.allow-header-cert-info',
      :value   => false,
    })}
  end

  context 'not defaults' do
    let(:params) do
      {
        :version                => 2,
        :allow_header_cert_info => true,
        :replace                => true,
        :path                   => '/tmp/foo',
      }
    end

    it { is_expected.to contain_concat('server-auth.conf').with({
      :path    => '/tmp/foo',
      :replace => true,
    })}

    it { is_expected.to contain_concat__fragment('00_header').with({
      :target => 'server-auth.conf',
    }).with_content(/authorization: \{\n  rules: \[\]\n/)}

    it { is_expected.to contain_concat__fragment('99_footer').with({
      :target => 'server-auth.conf',
    }).with_content(/\}\n/)}

    it { is_expected.to contain_hocon_setting('authorization.version').that_requires('Concat[server-auth.conf]').with({
      :path    => '/tmp/foo',
      :setting => 'authorization.version',
      :value   => 2,
    })}

    it { is_expected.to contain_hocon_setting('authorization.allow-header-cert-info').that_requires('Concat[server-auth.conf]').with({
      :path    => '/tmp/foo',
      :setting => 'authorization.allow-header-cert-info',
      :value   => true,
    })}
  end

  describe 'failures' do
    context 'bad path' do
      it_behaves_like "fail" do
        let(:params) {{:path => 'foo'}}
        let(:regex) { 'path' }
      end
    end

    context 'bad path 2' do
      it_behaves_like "fail" do
        let(:params) {{:path => 2}}
        let(:regex) { 'path' }
      end
    end

    context 'bad allow_header_cert_info' do
      it_behaves_like "fail" do
        let(:params) {{:allow_header_cert_info => 'foo'}}
        let(:regex) { 'allow_header_cert_info' }
      end
    end

    context 'bad replace' do
      it_behaves_like "fail" do
        let(:params) {{:replace => 'foo'}}
        let(:regex) { 'replace' }
      end
    end
  end

end
