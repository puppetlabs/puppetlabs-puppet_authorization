class puppet_authorization (
  Integer $version = 1,
  Boolean $allow_header_cert_info = false,
  Boolean $replace = false,
  String $path = '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
){
  validate_absolute_path($path)

  concat { 'server-auth.conf':
    path    => $path,
    replace => $replace,
  }

  concat::fragment { '00_header':
    target  => 'server-auth.conf',
    content => "authorization: {
  rules: []
"
  }

  concat::fragment { '99_footer':
    target  => 'server-auth.conf',
    content => "}
"
  }

  hocon_setting { 'authorization.version':
    path    => $path,
    setting => 'authorization.version',
    value   => $version,
    require => Concat['server-auth.conf'],
  }

  hocon_setting { 'authorization.allow-header-cert-info':
    path    => $path,
    setting => 'authorization.allow-header-cert-info',
    value   => $allow_header_cert_info,
    require => Concat['server-auth.conf'],
  }
}
