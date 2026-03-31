locals {
  arm_filename = "${path.module}/arm_site_config.json"

  app_settings = merge(
    try(var.settings.application_insight, null) == null ? {} : {
      "APPINSIGHTS_INSTRUMENTATIONKEY" = try(
        var.remote_objects.application_insights[var.settings.application_insight.lz_key][var.settings.application_insight.key].instrumentation_key,
        var.remote_objects.application_insights[var.client_config.landingzone_key][var.settings.application_insight.key].instrumentation_key,
        var.settings.application_insight.instrumentation_key,
      null),
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = try(
        var.remote_objects.application_insights[var.settings.application_insight.lz_key][var.settings.application_insight.key].connection_string,
        var.remote_objects.application_insights[var.client_config.landingzone_key][var.settings.application_insight.key].connection_string,
        var.settings.application_insight.connection_string,
      null),
      "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    },
    try(var.settings.app_settings, {}),
    try(local.dynamic_settings_to_process, {}),
  )
}