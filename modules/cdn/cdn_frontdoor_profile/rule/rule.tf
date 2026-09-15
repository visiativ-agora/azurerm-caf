# rule.tf
# Placeholder for azurerm_cdn_frontdoor_rule resource implementation

resource "azurerm_cdn_frontdoor_rule" "rule" {
  name = azurecaf_name.rule.result
  cdn_frontdoor_rule_set_id = coalesce(
    try(var.settings.cdn_frontdoor_rule_set_id, null),
    try(var.remote_objects.cdn_frontdoor_rule_sets[var.settings.rule_set_key].id, null),
    try(var.remote_objects.cdn_frontdoor_rule_sets[try(var.settings.rule_set.lz_key, var.client_config.landingzone_key)][var.settings.rule_set.key].id, null)
  )
  order              = var.settings.order
  behaviour_on_match = try(var.settings.behaviour_on_match, "Continue")

  # The actions block is required - create from actions array
  dynamic "actions" {
    for_each = try(var.settings.actions, [])
    content {
      dynamic "url_rewrite" {
        for_each = try(actions.value.url_rewrite, null) == null ? [] : [actions.value.url_rewrite]
        content {
          destination_path                = url_rewrite.value.destination_path
          source_pattern                  = url_rewrite.value.source_pattern
          preserve_unmatched_path_enabled = try(url_rewrite.value.preserve_unmatched_path_enabled, false)
        }
      }

      dynamic "url_redirect" {
        for_each = try(actions.value.url_redirect, null) == null ? [] : [actions.value.url_redirect]
        content {
          redirect_type         = url_redirect.value.redirect_type
          destination_host_name = try(length(trimspace(url_redirect.value.destination_host_name)) > 0 ? url_redirect.value.destination_host_name : null, null)
          redirect_protocol     = try(url_redirect.value.redirect_protocol, "MatchRequest")
          destination_path      = try(length(trimspace(url_redirect.value.destination_path)) > 0 ? url_redirect.value.destination_path : null, null)
          query_string          = try(length(trimspace(url_redirect.value.query_string)) > 0 ? url_redirect.value.query_string : null, null)
          destination_fragment  = try(length(trimspace(url_redirect.value.destination_fragment)) > 0 ? url_redirect.value.destination_fragment : null, null)
        }
      }

      dynamic "route_configuration_override" {
        for_each = try(actions.value.route_configuration_override, null) == null ? [] : [actions.value.route_configuration_override]
        content {
          dynamic "origin_group" {
            for_each = coalesce(
              try(route_configuration_override.value.cdn_frontdoor_origin_group_id, null),
              try(var.remote_objects.cdn_frontdoor_origin_groups[route_configuration_override.value.origin_group_key].id, null),
              try(var.remote_objects.cdn_frontdoor_origin_groups[try(route_configuration_override.value.origin_group.lz_key, var.client_config.landingzone_key)][route_configuration_override.value.origin_group.key].id, null)
            ) == null ? [] : [route_configuration_override.value]
            content {
              cdn_frontdoor_origin_group_id = coalesce(
                try(route_configuration_override.value.cdn_frontdoor_origin_group_id, null),
                try(var.remote_objects.cdn_frontdoor_origin_groups[route_configuration_override.value.origin_group_key].id, null),
                try(var.remote_objects.cdn_frontdoor_origin_groups[try(route_configuration_override.value.origin_group.lz_key, var.client_config.landingzone_key)][route_configuration_override.value.origin_group.key].id, null)
              )
              forwarding_protocol = route_configuration_override.value.forwarding_protocol
            }
          }

          dynamic "caching" {
            for_each = [route_configuration_override.value]
            content {
              duration                = try(caching.value.duration, null)
              query_string_behaviour  = try(caching.value.query_string_behaviour, "IgnoreQueryString")
              query_string_parameters = try(caching.value.query_string_parameters, null)
              compression_enabled     = try(caching.value.compression_enabled, null)
              behaviour               = try(caching.value.behaviour, "HonorOrigin")
            }
          }
        }
      }

      dynamic "modify_request_header" {
        for_each = try(actions.value.modify_request_header, [])
        content {
          operator     = modify_request_header.value.operator
          header_name  = modify_request_header.value.header_name
          header_value = try(modify_request_header.value.header_value, null)
        }
      }

      dynamic "modify_response_header" {
        for_each = try(actions.value.modify_response_header, [])
        content {
          operator     = modify_response_header.value.operator
          header_name  = modify_response_header.value.header_name
          header_value = try(modify_response_header.value.header_value, null)
        }
      }
    }
  }

  dynamic "conditions" {
    for_each = try(var.settings.conditions, [])
    content {
      dynamic "remote_address" {
        for_each = try(conditions.value.remote_address, [])
        content {
          operator = try(remote_address.value.negate_condition, false) ? (
            startswith(try(remote_address.value.operator, "IPMatch"), "Not") ? try(remote_address.value.operator, "IPMatch") : "Not${try(remote_address.value.operator, "IPMatch")}"
          ) : try(remote_address.value.operator, "IPMatch")
          values = try(remote_address.value.match_values, try(remote_address.value.values, []))
        }
      }

      dynamic "request_method" {
        for_each = try(conditions.value.request_method, [])
        content {
          operator = try(request_method.value.negate_condition, false) ? (
            startswith(try(request_method.value.operator, "Equal"), "Not") ? try(request_method.value.operator, "Equal") : "Not${try(request_method.value.operator, "Equal")}"
          ) : try(request_method.value.operator, "Equal")
          values = try(request_method.value.match_values, try(request_method.value.values, []))
        }
      }

      dynamic "query_string" {
        for_each = try(conditions.value.query_string, [])
        content {
          operator = try(query_string.value.negate_condition, false) ? (
            startswith(query_string.value.operator, "Not") ? query_string.value.operator : "Not${query_string.value.operator}"
          ) : query_string.value.operator
          values     = try(query_string.value.match_values, try(query_string.value.values, []))
          transforms = try(query_string.value.transforms, [])
        }
      }

      dynamic "post_argument" {
        for_each = try(conditions.value.post_argument, [])
        content {
          name = try(post_argument.value.post_args_name, try(post_argument.value.name, null))
          operator = try(post_argument.value.negate_condition, false) ? (
            startswith(post_argument.value.operator, "Not") ? post_argument.value.operator : "Not${post_argument.value.operator}"
          ) : post_argument.value.operator
          values     = try(post_argument.value.match_values, try(post_argument.value.values, []))
          transforms = try(post_argument.value.transforms, [])
        }
      }

      dynamic "request_url" {
        for_each = try(conditions.value.request_url, [])
        content {
          operator = try(request_url.value.negate_condition, false) ? (
            startswith(request_url.value.operator, "Not") ? request_url.value.operator : "Not${request_url.value.operator}"
          ) : request_url.value.operator
          values     = try(request_url.value.match_values, try(request_url.value.values, []))
          transforms = try(request_url.value.transforms, [])
        }
      }

      dynamic "request_header" {
        for_each = try(conditions.value.request_header, [])
        content {
          name = try(request_header.value.header_name, try(request_header.value.name, null))
          operator = try(request_header.value.negate_condition, false) ? (
            startswith(request_header.value.operator, "Not") ? request_header.value.operator : "Not${request_header.value.operator}"
          ) : request_header.value.operator
          values     = try(request_header.value.match_values, try(request_header.value.values, []))
          transforms = try(request_header.value.transforms, [])
        }
      }

      dynamic "request_body" {
        for_each = try(conditions.value.request_body, [])
        content {
          operator = try(request_body.value.negate_condition, false) ? (
            startswith(request_body.value.operator, "Not") ? request_body.value.operator : "Not${request_body.value.operator}"
          ) : request_body.value.operator
          values     = try(request_body.value.match_values, try(request_body.value.values, []))
          transforms = try(request_body.value.transforms, [])
        }
      }

      dynamic "request_scheme" {
        for_each = try(conditions.value.request_scheme, [])
        content {
          operator = try(request_scheme.value.negate_condition, false) ? (
            startswith(try(request_scheme.value.operator, "Equal"), "Not") ? try(request_scheme.value.operator, "Equal") : "Not${try(request_scheme.value.operator, "Equal")}"
          ) : try(request_scheme.value.operator, "Equal")
          values = try(request_scheme.value.match_values, try(request_scheme.value.values, []))
        }
      }

      dynamic "request_path" {
        for_each = try(conditions.value.request_path, [])
        content {
          operator = try(request_path.value.negate_condition, false) ? (
            startswith(request_path.value.operator, "Not") ? request_path.value.operator : "Not${request_path.value.operator}"
          ) : request_path.value.operator
          values     = try(request_path.value.match_values, try(request_path.value.values, []))
          transforms = try(request_path.value.transforms, [])
        }
      }

      dynamic "request_file_extension" {
        for_each = try(conditions.value.request_file_extension, [])
        content {
          operator = try(request_file_extension.value.negate_condition, false) ? (
            startswith(request_file_extension.value.operator, "Not") ? request_file_extension.value.operator : "Not${request_file_extension.value.operator}"
          ) : request_file_extension.value.operator
          values     = try(request_file_extension.value.match_values, try(request_file_extension.value.values, []))
          transforms = try(request_file_extension.value.transforms, [])
        }
      }

      dynamic "request_filename" {
        for_each = try(conditions.value.request_filename, [])
        content {
          operator = try(request_filename.value.negate_condition, false) ? (
            startswith(request_filename.value.operator, "Not") ? request_filename.value.operator : "Not${request_filename.value.operator}"
          ) : request_filename.value.operator
          values     = try(request_filename.value.match_values, try(request_filename.value.values, []))
          transforms = try(request_filename.value.transforms, [])
        }
      }

      dynamic "http_version" {
        for_each = try(conditions.value.http_version, [])
        content {
          operator = try(http_version.value.negate_condition, false) ? (
            startswith(try(http_version.value.operator, "Equal"), "Not") ? try(http_version.value.operator, "Equal") : "Not${try(http_version.value.operator, "Equal")}"
          ) : try(http_version.value.operator, "Equal")
          values = try(http_version.value.match_values, try(http_version.value.values, []))
        }
      }

      dynamic "request_cookies" {
        for_each = try(conditions.value.request_cookies, [])
        content {
          name = try(request_cookies.value.cookie_name, try(request_cookies.value.name, null))
          operator = try(request_cookies.value.negate_condition, false) ? (
            startswith(request_cookies.value.operator, "Not") ? request_cookies.value.operator : "Not${request_cookies.value.operator}"
          ) : request_cookies.value.operator
          values     = try(request_cookies.value.match_values, try(request_cookies.value.values, []))
          transforms = try(request_cookies.value.transforms, [])
        }
      }

      dynamic "device_type" {
        for_each = try(conditions.value.device_type, [])
        content {
          operator = try(device_type.value.negate_condition, false) ? (
            startswith(try(device_type.value.operator, "Equal"), "Not") ? try(device_type.value.operator, "Equal") : "Not${try(device_type.value.operator, "Equal")}"
          ) : try(device_type.value.operator, "Equal")
          values = try(device_type.value.match_values, try(device_type.value.values, []))
        }
      }

      dynamic "socket_address" {
        for_each = try(conditions.value.socket_address, [])
        content {
          operator = try(socket_address.value.negate_condition, false) ? (
            startswith(try(socket_address.value.operator, "IPMatch"), "Not") ? try(socket_address.value.operator, "IPMatch") : "Not${try(socket_address.value.operator, "IPMatch")}"
          ) : try(socket_address.value.operator, "IPMatch")
          values = try(socket_address.value.match_values, try(socket_address.value.values, []))
        }
      }

      dynamic "client_port" {
        for_each = try(conditions.value.client_port, [])
        content {
          operator = try(client_port.value.negate_condition, false) ? (
            startswith(client_port.value.operator, "Not") ? client_port.value.operator : "Not${client_port.value.operator}"
          ) : client_port.value.operator
          values = try(client_port.value.match_values, try(client_port.value.values, []))
        }
      }

      dynamic "server_port" {
        for_each = try(conditions.value.server_port, [])
        content {
          operator = try(server_port.value.negate_condition, false) ? (
            startswith(server_port.value.operator, "Not") ? server_port.value.operator : "Not${server_port.value.operator}"
          ) : server_port.value.operator
          values = try(server_port.value.match_values, try(server_port.value.values, []))
        }
      }

      dynamic "host_name" {
        for_each = try(conditions.value.host_name, [])
        content {
          operator = try(host_name.value.negate_condition, false) ? (
            startswith(host_name.value.operator, "Not") ? host_name.value.operator : "Not${host_name.value.operator}"
          ) : host_name.value.operator
          values     = try(host_name.value.match_values, try(host_name.value.values, []))
          transforms = try(host_name.value.transforms, [])
        }
      }

      dynamic "ssl_protocol" {
        for_each = try(conditions.value.ssl_protocol, [])
        content {
          operator = try(ssl_protocol.value.negate_condition, false) ? (
            startswith(try(ssl_protocol.value.operator, "Equal"), "Not") ? try(ssl_protocol.value.operator, "Equal") : "Not${try(ssl_protocol.value.operator, "Equal")}"
          ) : try(ssl_protocol.value.operator, "Equal")
          values = try(ssl_protocol.value.match_values, try(ssl_protocol.value.values, []))
        }
      }
    }
  }

  dynamic "timeouts" {
    for_each = try(var.settings.timeouts, null) == null ? [] : [var.settings.timeouts]
    content {
      create = try(timeouts.value.create, null)
      update = try(timeouts.value.update, null)
      read   = try(timeouts.value.read, null)
      delete = try(timeouts.value.delete, null)
    }
  }
}
