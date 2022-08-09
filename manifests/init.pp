# Sets up the skeleton server `auth.conf` file if it doesn't exist
#
# @param version
#   The `authorization.version` setting in the server auth.conf.
#   Valid options: an integer (currently, 1 is the only supported value).
#
# @param allow_header_cert_info
#   The `authorization.allow-header-cert-info` setting in the server auth.conf
#
# @param replace
#   Whether or not to replace existing file at `path`. If set to true this will
#   cause the file to be regenerated on every puppet run
#
# @param path
#   Absolute path for `auth.conf`
#
#
# @example
#
#   puppet_authorization { '/etc/puppetlabs/puppetserver/conf.d/auth.conf':
#     version                => 1,
#     allow_header_cert_info => false
#   }
#
define puppet_authorization (
  Integer $version = 1,
  Boolean $allow_header_cert_info = false,
  Boolean $replace = false,
  Stdlib::Absolutepath $path = $name,
){
  concat { $name:
    path    => $path,
    replace => $replace,
  }

  concat::fragment { "00_header_${name}":
    target  => $name,
    content => "authorization: {
  rules: []
",
  }

  concat::fragment { "99_footer_${name}":
    target  => $name,
    content => "}
",
  }

  hocon_setting { "authorization.version.${name}":
    path    => $path,
    setting => 'authorization.version',
    value   => $version,
    require => Concat[$name],
  }

  hocon_setting { "authorization.allow-header-cert-info.${name}":
    path    => $path,
    setting => 'authorization.allow-header-cert-info',
    value   => $allow_header_cert_info,
    require => Concat[$name],
  }
}
