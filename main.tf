locals {
  # Validation for Routed network ranges - they should not have DHCP configuration fields with values
  routed_dhcp_validation = {
    for idx, row in var.network_range_data : idx => {
      is_routed = row.range_type == "Routed"
      has_invalid_dhcp_settings = (
        (try(row.dhcp_ip_range, null) != null && try(row.dhcp_ip_range, "") != "") ||
        (try(row.dhcp_relay_group_id, null) != null && try(row.dhcp_relay_group_id, "") != "") ||
        (try(row.dhcp_relay_group_name, null) != null && try(row.dhcp_relay_group_name, "") != "") ||
        (try(row.dhcp_microsegmentation, null) != null && try(row.dhcp_microsegmentation, false) != false && lower(tostring(try(row.dhcp_microsegmentation, false))) == "true")
      )
      error_message = "Routed network range '${row.name}' (${row.subnet}) cannot have DHCP configuration fields (dhcp_ip_range, dhcp_relay_group_id, dhcp_relay_group_name, dhcp_microsegmentation) set to non-empty/non-false values. For Routed ranges, only dhcp_type can be empty, DHCP_DISABLED, or ACCOUNT_DEFAULT."
    }
  }

  # Trigger validation errors for invalid Routed ranges
  validation_errors = [
    for idx, validation in local.routed_dhcp_validation :
    validation.error_message
    if validation.is_routed && validation.has_invalid_dhcp_settings
  ]

  # Use regex to force an error if there are validation issues
  validation_check = length(local.validation_errors) > 0 ? regex(
    join("\n", local.validation_errors), 
    "validation_failed"
  ) : "validation_passed"

  network_ranges = [for row in var.network_range_data : {
    # id                 = row.id
    site_id            = row.site_id
    interface_id       = try(row.interface_id, null)
    interface_index    = row.interface_index
    name               = row.name
    range_type         = row.range_type
    subnet             = row.subnet
    local_ip           = (try(row.local_ip, null) != null && try(row.local_ip, "") != "") ? row.local_ip : null
    gateway            = (try(row.gateway, null) != null && try(row.gateway, "") != "") ? row.gateway : null
    vlan               = (try(row.vlan, null) != null && try(row.vlan, "") != "") ? tonumber(row.vlan) : null
    translated_subnet  = (try(row.translated_subnet, null) != null && try(row.translated_subnet, "") != "") ? row.translated_subnet : null
    internet_only      = try(row.internet_only, null) == null ? false : (row.internet_only == true || lower(tostring(row.internet_only)) == "true")
    mdns_reflector     = try(row.mdns_reflector, null) == null ? false : (row.mdns_reflector == true || lower(tostring(row.mdns_reflector)) == "true") && row.range_type != "Routed"
    dhcp_settings = (try(row.dhcp_type, null) != null && try(row.dhcp_type, "") != "") ? {
      dhcp_type              = row.dhcp_type
      ip_range               = (row.dhcp_type != "DHCP_DISABLED" && try(row.dhcp_ip_range, null) != null && try(row.dhcp_ip_range, "") != "") ? row.dhcp_ip_range : null
      relay_group_id         = (row.dhcp_type == "DHCP_RELAY" && try(row.dhcp_relay_group_id, null) != null && try(row.dhcp_relay_group_id, "") != "") ? row.dhcp_relay_group_id : null
      relay_group_name       = (row.dhcp_type == "DHCP_RELAY" && try(row.dhcp_relay_group_name, null) != null && try(row.dhcp_relay_group_name, "") != "") ? row.dhcp_relay_group_name : null
      dhcp_microsegmentation = try(row.dhcp_microsegmentation, null) == null ? false : (row.dhcp_microsegmentation == true || lower(tostring(row.dhcp_microsegmentation)) == "true")
    } : null
  }]
}

module "network_range" {
  source             = "./modules/network_range"
  # Index by network range name with index for uniqueness
  for_each           = { for idx, network_range in local.network_ranges :
    "${network_range.name}_${idx}" => network_range
  }
  
  site_id            = each.value.site_id
  interface_id       = each.value.interface_id
  interface_index    = each.value.interface_index
  name               = each.value.name
  range_type         = each.value.range_type
  subnet             = each.value.subnet
  local_ip           = each.value.local_ip
  gateway            = each.value.gateway
  vlan               = each.value.vlan
  translated_subnet  = each.value.translated_subnet
  internet_only      = each.value.internet_only
  mdns_reflector     = each.value.mdns_reflector
  dhcp_settings      = each.value.dhcp_settings
}
