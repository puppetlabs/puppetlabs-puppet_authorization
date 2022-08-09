# Adds/removes individual rules in `auth.conf`
#
# @example Grant (only) `'your.special.admin'` access to the `/puppet/v3/environments` endpoint
#
#   puppet_authorization::rule { 'environments':
#     match_request_path         => '/puppet/v3/environments',
#     match_request_type         => 'path',
#     match_request_method       => 'get',
#     allow                      => 'your.special.admin',
#     sort_order                 => 300,
#     path                       => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
#   }
#
#
# @example Delete the `environments` rule (from the previous example)
#
#   # When removing a rule, you have only to provide the rule name and path to
#   # the configuration file where it can be found.
#   #
#   # Since rules must have unique names, you don't have to define the other
#   # attributes (`match_request_path`, etc); the rule with the matching name
#   # will be removed, regardless.
#   puppet_authorization::rule { 'environments':
#     ensure                     => absent,
#     path                       => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
#   }
#
#
# @example Configure the catalog endpoint
#
#   # You can configure the catalog HTTP endpoint for Puppet Server to:
#   #
#   #   * Permit an administrative node to access the catalog for any node.
#   #   * Permit other nodes to be able to access their own catalog, but no
#   #     other node’s catalog.
#
#   # This example rule applies only to requests made to the `production` or
#   # `test` directory environments in Puppet:
#   puppet_authorization::rule { 'catalog_request':
#     match_request_path         => '^/puppet/v3/catalog/([^/]+)$',
#     match_request_type         => 'regex',
#     match_request_method       => ['get','post'],
#     match_request_query_params => {'environment' => [ 'production', 'test' ]},
#     allow                      => ['$1', 'adminhost.mydomain.com'],
#     sort_order                 => 200,
#     path                       => '/etc/puppetlabs/puppetserver/conf.d/auth.conf',
#   }
#
#
# @param match_request_path
#
# @param match_request_type
#   The type of match request
#
# @param path
#   The absolute path for the auth.conf file.
#
# @param ensure
#   Whether to add or remove the rule
#
# @param rule_name
#   The `name` setting for the rule
#
# @param allow
#   The `allow` setting for the rule.
#
#   * Cannot be set along with an `allow_unauthenticated` value of true
#   * A hash here must contain only one of `extensions` or `certname`
#
#   For more details on the `allow` setting, see https://github.com/puppetlabs/trapperkeeper-authorization/blob/master/doc/authorization-config.md#allow
#
# @param deny
#   The `deny` setting for the rule.
#
#   * Cannot be set along with an`allow_unauthenticated` value of true.
#   * A hash here must contain only one of `extensions` or `certname`.
#
#   For more details on the
#   `deny` setting, see
#   https://github.com/puppetlabs/trapperkeeper-authorization/blob/master/doc/authorization-config.md#deny.
#
# @param allow_unauthenticated
#   The `allow_unauthenticated` setting for the rule.
#
#   * Cannot be set to true along with `deny` or `allow`
#
# @param match_request_method
#   The `method` setting for the `match_request` in the rule.
#
#   Valid options: String or array of strings containing: 'put', 'post', 'get', 'head', 'delete'.
#
# @param match_request_query_params
#   The `query_params` setting for the `match_request` in the rule
#
# @param sort_order
#   The sort order for the rule
#
#
define puppet_authorization::rule (
  Optional[String] $match_request_path                                                                          = undef,
  Optional[Enum['path', 'regex']] $match_request_type                                                           = undef,
  Stdlib::Absolutepath $path,
  Enum['present', 'absent'] $ensure                                                                             = 'present',
  String $rule_name                                                                                             = $name,
  Variant[Array[Variant[String, Hash]], String, Hash, Undef] $allow                                             = undef,
  Boolean $allow_unauthenticated                                                                                = false,
  Variant[Array[Variant[String, Hash]], String, Hash, Undef] $deny                                              = undef,
  Variant[Array[Puppet_authorization::Httpmethod], Puppet_authorization::Httpmethod, Undef] $match_request_method = undef,
  Hash $match_request_query_params                                                                              = {},
  Integer $sort_order                                                                                           = 200
) {
  if $ensure == 'present' {
    if $allow_unauthenticated and ($allow or $deny) {
      fail('$allow and $deny cannot be specified if $allow_unauthenticated is true')
    } elsif ! $allow and ! $deny and ! $allow_unauthenticated {
      fail('One of $allow or $deny is required if $allow_unauthenticated is false')
    }
  }

  if $match_request_method {
    $match_request = {
      'path'         => $match_request_path,
      'type'         => $match_request_type,
      'query-params' => $match_request_query_params,
      'method'       => $match_request_method,
    }
  } else {
    $match_request = {
      'path'         => $match_request_path,
      'type'         => $match_request_type,
      'query-params' => $match_request_query_params,
    }
  }

  if $allow and $deny {
    $rule = {
      'match-request' => $match_request,
      'allow'         => $allow,
      'deny'          => $deny,
      'name'          => $rule_name,
      'sort-order'    => $sort_order,
    }
  } elsif $allow {
    $rule = {
      'match-request' => $match_request,
      'allow'         => $allow,
      'name'          => $rule_name,
      'sort-order'    => $sort_order,
    }
  } elsif $deny {
    $rule = {
      'match-request' => $match_request,
      'deny'          => $deny,
      'name'          => $rule_name,
      'sort-order'    => $sort_order,
    }
  } else {
    $rule = {
      'match-request'         => $match_request,
      'allow-unauthenticated' => $allow_unauthenticated,
      'name'                  => $rule_name,
      'sort-order'            => $sort_order,
    }
  }

  puppet_authorization_hocon_rule { "rule-${name}":
    ensure => $ensure,
    path   => $path,
    value  => $rule,
  }
}
