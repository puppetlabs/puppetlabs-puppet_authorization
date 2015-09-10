class http_authorization (
  Integer $version = 1,
  Boolean $allow_header_cert_info = false,
  Boolean $replace = false,
  String $path = "${::settings::confdir}/auth.conf",
){
  validate_absolute_path($path)

  concat { $path:
    replace => $replace,
  }

  concat::fragment { '00_header':
    target  => $path,
    content => "authorization: {
  rules: []
"
  }

  concat::fragment { '99_footer':
    target  => $path,
    content => "}
"
  }

  hocon_setting { 'authorization.version':
    path    => $path,
    setting => 'authorization.version',
    value   => $version,
    require => Concat[$path],
  }

  hocon_setting { 'authorization.allow-header-cert-info':
    path    => $path,
    setting => 'authorization.allow-header-cert-info',
    value   => $allow_header_cert_info,
    require => Concat[$path],
  }
}
