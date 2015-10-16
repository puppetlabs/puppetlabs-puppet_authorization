# puppet_authorization

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with puppet_authorization](#setup)
    * [What puppet_authorization affects](#what-puppet_authorization-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with puppet_authorization](#beginning-with-puppet_authorization)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

A one-maybe-two sentence summary of what the module does/what problem it solves.
This is your 30 second elevator pitch for your module. Consider including
OS/Puppet version it works with.

## Module Description

If applicable, this section should have a brief description of the technology
the module integrates with and what that integration enables. This section
should answer the questions: "What does this module *do*?" and "Why would I use
it?"

If your module has a range of functionality (installation, configuration,
management, etc.) this is the time to mention it.

## Setup

### What puppet_authorization affects

* A list of files, packages, services, or operations that the module will alter,
  impact, or execute on the system it's installed on.
* This is a great place to stick any warnings.
* Can be in list or paragraph form.

### Setup Requirements **OPTIONAL**

If your module requires anything extra before setting up (pluginsync enabled,
etc.), mention it here.

### Beginning with puppet_authorization

The very basic steps needed for a user to get the module up and running.

If your most recent release breaks compatibility or requires particular steps
for upgrading, you may wish to include an additional section here: Upgrading
(For an example, see http://forge.puppetlabs.com/puppetlabs/firewall).

## Usage

Put the classes, types, and resources for customizing, configuring, and doing
the fancy stuff with your module here.

## Reference

### Classes

* [`puppet_authorization`](#class-puppet_authorization)

### Defines

* [`puppet_authorization::rule`](#define-puppet_authorizationrule)

### Providers

* [`puppet_authorization`](#provider-puppet_authorization)

#### Class: `puppet_authorization`

Main class, sets up the skeleton server auth.conf file if it doesn't exist.

##### Parameters (all optional)

* `version`: The `authorization.version` setting in the server auth.conf. Valid options: an integer. Default: 1

* `allow_header_cert_info`: The `authorization.allow-header-cert-info` setting in the server auth.conf. Valid options: `true`, `false`. Default: `false`

* `replace`: Whether or not to replace existing file at `path`. If set to true this will cause the file to be regenerated on every puppet run. Valid options: `true`, `false`. Default: `false`

* `path`: Absolute path for auth.conf. Defaults to `${::settings::confdir}/auth.conf`.

#### Define: `puppet_authorization::rule`

Add individual rules to auth.conf.

##### Parameters (optional unless otherwise specified)

* `match_request_path`: Required. Valid options: a string.

* `match_request_type`: Required. Valid options: `'path'`, `'regex'`

* `ensure`: Whether to add or remove the rule. Valid options: `'present'`, `'absent'`. Defaults to `'present'`

* `rule_name`: The `name` setting for the rule. Valid options: a string. Defaults to `name`.

* `allow`: The `allow` setting for the rule. Cannot be set along with an `allow_unauthenticated` value of `true`. Valid options: a string or an array of strings. Defaults to `undef`.

* `deny`: The `deny` setting for the rule. Cannot be set along with an `allow_unauthenticated` value of `true`. Valid options: a string or an array of strings. Defaults to `undef`.

* `allow_unauthenticated`: The `allow_unauthenticated` setting for the rule. Cannot be set to `true` along with `deny` or `allow`. Valid options: `true`, `false`. Defaults to `false`.

* `match_request_method`: The `method` setting for the `match_request` in the rule. Valid options: String or array of strings containing: `'put'`, `'post'`, `'get'`, `'head'`, `'delete'`. Defaults to `undef`.

* `match_request_query_params`: The `query_params` setting for the `match_request` in the rule. Valid options: Hash. Defaults to `{}`

* `sort_order`: The sort order for the rule. Valid options: an integer. Defaults to `200`

* `path`: The absolute path for the auth.conf file. Defaults to `$puppet_authorization::path`

## Limitations

This is where you list OS compatibility, version compatibility, etc.

## Development

Since your module is awesome, other users will want to play with it. Let them
know what the ground rules for contributing are.

## Release Notes/Contributors/Etc **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You may also add any additional sections you feel are
necessary or important to include here. Please use the `## ` header.
