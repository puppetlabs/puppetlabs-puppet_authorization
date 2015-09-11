define http_authorization::rule (
  String $match_request_path,
  Enum['path', 'regex'] $match_request_type,
  Enum['present', 'absent'] $ensure = 'present',
  String $rule_name = $name,
  Optional[String] $allow = undef,
  Boolean $allow_unauthenticated = false,
  Optional[String] $deny = undef,
  Variant[Array, String, Undef] $match_request_method = undef,
  Hash $match_request_query_params = {},
  Integer $sort_order = 200,
  String $path = $http_authorization::path,
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
    fail('$allow and $deny cannot be specified if $allow_unauthenticated is true')
  } elsif $allow and $deny {
    fail('Only one of $allow or $deny can be specified')
  } elsif not $allow and not $deny and not $allow_unauthenticated {
    fail('One of $allow or $deny is required if $allow_unauthenticated is false')
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

  if $allow {
    $allow_or_deny_key = 'allow'
    $allow_or_deny_val = $allow
  } elsif $deny {
    $allow_or_deny_key = 'deny'
    $allow_or_deny_val = $deny
  } else {
    $allow_or_deny_key = 'allow-unauthenticated'
    $allow_or_deny_val = $allow_unauthenticated
  }

  $rule = {
    'match-request'    => $match_request,
    $allow_or_deny_key => $allow_or_deny_val,
    'name'             => $rule_name,
    'sort-order'       => $sort_order,
  }

  # requires https://github.com/puppetlabs/puppetlabs-hocon/pull/23
  hocon_setting { "rule-${name}":
    path    => $path,
    setting => 'authorization.rules',
    value   => $rule,
    type    => 'array_element',
  }
}
