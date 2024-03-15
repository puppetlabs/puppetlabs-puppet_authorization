# @summary manage a puppetserver authorization rule
#
# @param path
#   The path to the auth.conf file
# @param ensure
#   State of rule
# @param rule_name
#   An arbitrary name used to identity the rule
# @param allow
#   Value(s) to permit an authenticated request
# @param allow_unauthenticated
#   Puppet Server will always permit the request (potentially insecure) when set to true.
#   If true, the rule cannot use the allow or deny parameters.
# @param deny
#   Value(s) to deny an authenticated request, even if an allow is also matched.
# @param match_request_method
#   Limit rule to match specific HTTP request method(s).
# @param match_request_query_params
#   Limit rule to matching query parameters with specific value(s).
#   An Array of values can be provided to match a request with any of the values.
# @param sort_order
#   Rule processing priority, 1 to 399 are evaluated before default Puppet rules, or 601 to 998 are be evaluated after Puppet.
#   Lower-numbered values evaluated first, and secondarily sorts lexicographically by the name string value's Unicode code points.
# @param match_request_path
#   Match request when the endpoint URL starts with or contains the parameter value.
# @param match_request_type
#   How Puppet Server will interpret the match_request_path parameter value.
#
define puppet_authorization::rule (
  Stdlib::Absolutepath $path,
  Enum['present', 'absent'] $ensure                                                                             = 'present',
  String $rule_name                                                                                             = $name,
  Variant[Array[Variant[String, Hash]], String, Hash, Undef] $allow                                             = undef,
  Boolean $allow_unauthenticated                                                                                = false,
  Variant[Array[Variant[String, Hash]], String, Hash, Undef] $deny                                              = undef,
  Variant[Array[Puppet_authorization::Httpmethod], Puppet_authorization::Httpmethod, Undef] $match_request_method = undef,
  Hash $match_request_query_params                                                                              = {},
  Integer $sort_order                                                                                           = 200,
  Optional[String] $match_request_path                                                                          = undef,
  Optional[Enum['path', 'regex']] $match_request_type                                                           = undef
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
