define puppet_authorization::rule (
  String $match_request_path,
  Enum['path', 'regex'] $match_request_type,
  String $path,
  Enum['present', 'absent'] $ensure = 'present',
  String $rule_name = $name,
  Variant[Array, String, Undef] $allow = undef,
  Boolean $allow_unauthenticated = false,
  Variant[Array, String, Undef] $deny = undef,
  Variant[Array, String, Undef] $match_request_method = undef,
  Hash $match_request_query_params = {},
  Integer $sort_order = 200
) {
  if $match_request_method =~ String {
    validate_re($match_request_method, '^(put|post|get|head|delete)$')
  } elsif $match_request_method =~ Array {
    $match_request_method.each |$method| {
      validate_re($method, '^(put|post|get|head|delete)$')
    }
  }

  validate_absolute_path($path)

  if $allow_unauthenticated and ($allow or $deny) {
    fail(
      '$allow and $deny cannot be specified if $allow_unauthenticated is true')
  } elsif ! $allow and ! $deny and ! $allow_unauthenticated {
    fail(
      'One of $allow or $deny is required if $allow_unauthenticated is false')
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

  hocon_setting { "rule-${name}":
    ensure   => $ensure,
    path     => $path,
    setting  => 'authorization.rules',
    value    => $rule,
    type     => 'array_element',
    provider => 'puppet_authorization',
  }
}
