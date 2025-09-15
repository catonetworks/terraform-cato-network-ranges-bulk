# Terraform Cato Network Ranges Bulk Module

This Terraform module allows you to create multiple Cato network ranges in bulk using CSV or JSON input data. It simplifies the process of configuring multiple network ranges with their associated DHCP settings by accepting either CSV-decoded data or JSON arrays and automatically transforming them into the required nested structure.

## Features

- **Bulk Creation**: Create multiple network ranges from a single data source
- **Flexible Input**: Accepts both CSV and JSON input formats
- **DHCP Configuration**: Supports all DHCP types (DISABLED, ACCOUNT_DEFAULT, DHCP_RELAY, DHCP_RANGE)
- **Boolean Parsing**: Handles case-insensitive boolean values from CSV data
- **Validation**: Built-in validation for subnet types and mDNS reflector constraints
- **Environment Variables**: Uses standard Cato environment variables for authentication

## Prerequisites

- Terraform >= 1.0
- Cato Terraform Provider >= 0.0.39
- Valid Cato API token and Account ID

## Required Environment Variables

```bash
export CATO_TOKEN="your-cato-api-token"
export CATO_ACCOUNT_ID="your-account-id"
```

## Usage

### Basic Usage with CSV

```hcl
module "network_ranges" {
  source             = "catonetworks/network-ranges-bulk/cato"
  network_range_data = csvdecode(file("${path.module}/network_ranges.csv"))
}
```

### Usage with JSON

```hcl
module "network_ranges" {
  source             = "catonetworks/network-ranges-bulk/cato"
  network_range_data = jsondecode(file("${path.module}/network_ranges.json"))
}
```

### Complete Example

```hcl
terraform {
  required_providers {
    cato = {
      source  = "catonetworks/cato"
      version = "~> 0.0.39"
    }
  }
}

provider "cato" {
  # Uses CATO_TOKEN and CATO_ACCOUNT_ID environment variables
}

module "network_ranges" {
  source             = "catonetworks/network-ranges-bulk/cato"
  network_range_data = csvdecode(file("${path.module}/network_ranges.csv"))
}

# Optional: Output the created network ranges
output "network_ranges" {
  value = module.network_ranges.network_ranges
}
```

## Input Data Format

### CSV Format

The CSV file should contain the following columns (header row required):

| Column | Required | Description | Example |
|--------|----------|-------------|---------|
| `site_id` | Yes | Site ID where the network range will be created | `144905` |
| `interface_index` | Yes | Interface index (e.g., INT_5) | `INT_5` |
| `name` | Yes | Name of the network range | `Net1Routed` |
| `range_type` | Yes | Type of network range (Routed, Direct, VLAN) | `VLAN` |
| `subnet` | Yes | Network subnet in CIDR notation | `10.0.1.0/24` |
| `local_ip` | No | Local IP address (required for Direct/VLAN) | `10.0.1.1` |
| `gateway` | No | Gateway IP address (for Routed type) | `192.169.11.2` |
| `vlan` | No | VLAN ID (for VLAN type) | `4` |
| `translated_subnet` | No | Translated subnet in CIDR notation | `172.167.1.0/24` |
| `internet_only` | No | Internet-only access (true/false) | `TRUE` |
| `mdns_reflector` | No | mDNS reflector enabled (true/false, not for Routed) | `TRUE` |
| `dhcp_type` | No | DHCP configuration type | `DHCP_RANGE` |
| `dhcp_ip_range` | No | IP range for DHCP_RANGE type | `10.0.8.100-10.0.8.200` |
| `dhcp_relay_group_id` | No | DHCP relay group ID | `3365` |
| `dhcp_relay_group_name` | No | DHCP relay group name | `dhcp_relay1` |
| `dhcp_microsegmentation` | No | DHCP microsegmentation (true/false) | `TRUE` |

### Sample CSV

```csv
site_id,interface_index,name,range_type,subnet,local_ip,gateway,vlan,translated_subnet,internet_only,mdns_reflector,dhcp_type,dhcp_ip_range,dhcp_relay_group_id,dhcp_relay_group_name,dhcp_microsegmentation
144905,INT_5,Net1Routed,Routed,10.0.1.0/24,,192.169.11.2,,172.167.1.0/24,,,,,,,
144905,INT_5,Net1Routed,Routed,10.0.2.0/24,,192.169.11.3,,,TRUE,,,,,,
144905,INT_5,Net3Direct,Direct,10.0.3.0/24,10.0.3.1,,,172.167.3.0/24,,TRUE,,,,,
144905,INT_5,NetVLAN4,VLAN,10.0.4.0/24,10.0.4.1,,4,,,,DHCP_DISABLED,,,,
144905,INT_5,NetVLAN5,VLAN,10.0.5.0/24,10.0.5.1,,5,172.167.5.0/24,,,ACCOUNT_DEFAULT,,,,
144905,INT_5,NetVLAN6,VLAN,10.0.6.0/24,10.0.6.1,,6,172.167.6.0/24,,,DHCP_RELAY,,,dhcp_relay1,
144905,INT_5,NetVLAN7,VLAN,10.0.7.0/24,10.0.7.1,,7,,,,DHCP_RELAY,,3365,,
144905,INT_5,NetVLAN8,VLAN,10.0.8.0/24,10.0.8.1,,8,172.167.8.0/24,,,DHCP_RANGE,10.0.8.100-10.0.8.200,,,TRUE
```

### JSON Format

```json
[{
  "site_id": "144905",
  "interface_index": "INT_5",
  "name": "Net1Routed",
  "range_type": "Routed",
  "subnet": "10.0.1.0/24",
  "gateway": "192.169.11.2",
  "translated_subnet": "172.167.1.0/24"
}, {
  "site_id": "144905",
  "interface_index": "INT_5",
  "name": "NetVLAN8",
  "range_type": "VLAN",
  "subnet": "10.0.8.0/24",
  "local_ip": "10.0.8.1",
  "vlan": "8",
  "translated_subnet": "172.167.8.0/24",
  "dhcp_type": "DHCP_RANGE",
  "dhcp_ip_range": "10.0.8.100-10.0.8.200",
  "dhcp_microsegmentation": true
}]
```

## Sample Data

You can find sample data files in the repository:

- [network_ranges.csv](https://github.com/catonetworks/terraform-cato-network-ranges-bulk/blob/main/sample_data/network_ranges.csv) - Sample CSV format
- [network_ranges.json](https://github.com/catonetworks/terraform-cato-network-ranges-bulk/blob/main/sample_data/network_ranges.json) - Sample JSON format

## DHCP Configuration Types

The module supports the following DHCP types:

- **DHCP_DISABLED**: No DHCP service
- **ACCOUNT_DEFAULT**: Use account default DHCP settings
- **DHCP_RELAY**: Use DHCP relay (requires `dhcp_relay_group_id` or `dhcp_relay_group_name`)
- **DHCP_RANGE**: Use DHCP with specific IP range (requires `dhcp_ip_range`)

## Validation Rules

The module enforces the following validation rules:

1. **mDNS Reflector**: Cannot be enabled for Routed subnet types
2. **DHCP Relay**: When using `DHCP_RELAY`, either `dhcp_relay_group_id` or `dhcp_relay_group_name` must be specified
3. **Boolean Values**: CSV boolean values are parsed case-insensitively (`TRUE`, `true`, `True`, etc.)
4. **Required Fields**: Validates that required fields are present based on subnet type

## Outputs

- `network_ranges`: Map of all created network range resources

## Module Structure

```
terraform-cato-network-ranges-bulk/
├── main.tf              # Main module logic and data processing
├── variables.tf         # Input variable definitions
├── outputs.tf           # Output definitions
├── modules/
│   └── network_range/   # Child module for individual network ranges
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── sample_data/         # Sample input files
│   ├── network_ranges.csv
│   └── network_ranges.json
└── README.md
```

## Error Handling

The module handles common configuration errors:

- **Empty boolean values**: Treated as `false`
- **Case sensitivity**: Boolean values parsed case-insensitively
- **Missing DHCP fields**: Provides sensible defaults
- **Invalid subnet types**: Terraform will validate during plan/apply

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with sample data
5. Submit a pull request

## License

This module is provided under the Apache 2.0 License. See LICENSE file for details.

## Support

For issues and questions:

- Create an issue in the GitHub repository
- Consult the Cato Networks documentation
- Contact Cato Networks support

## Version History

- **v1.0.0**: Initial release with CSV/JSON support and DHCP configuration

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_cato"></a> [cato](#requirement\_cato) | >= 0.0.43 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network_range"></a> [network\_range](#module\_network\_range) | ./modules/network_range | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_network_range_data"></a> [network\_range\_data](#input\_network\_range\_data) | Network range data - can be CSV decoded data or JSON array with flat structure | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_configuration_summary"></a> [configuration\_summary](#output\_configuration\_summary) | Summary of all network range configurations |
| <a name="output_creation_summary"></a> [creation\_summary](#output\_creation\_summary) | Summary of the bulk network range creation process |
| <a name="output_dhcp_count_by_type"></a> [dhcp\_count\_by\_type](#output\_dhcp\_count\_by\_type) | Count of DHCP configurations by type |
| <a name="output_dhcp_disabled_ranges"></a> [dhcp\_disabled\_ranges](#output\_dhcp\_disabled\_ranges) | Network ranges that have DHCP disabled or no DHCP configuration |
| <a name="output_dhcp_enabled_ranges"></a> [dhcp\_enabled\_ranges](#output\_dhcp\_enabled\_ranges) | Network ranges that have DHCP configuration enabled |
| <a name="output_dhcp_ranges_by_type"></a> [dhcp\_ranges\_by\_type](#output\_dhcp\_ranges\_by\_type) | DHCP-enabled network ranges grouped by DHCP type |
| <a name="output_feature_usage_stats"></a> [feature\_usage\_stats](#output\_feature\_usage\_stats) | Statistics on feature usage across all network ranges |
| <a name="output_input_data_count"></a> [input\_data\_count](#output\_input\_data\_count) | Number of network range entries processed from input data |
| <a name="output_internet_only_ranges"></a> [internet\_only\_ranges](#output\_internet\_only\_ranges) | Network ranges configured for internet-only access |
| <a name="output_mdns_reflector_ranges"></a> [mdns\_reflector\_ranges](#output\_mdns\_reflector\_ranges) | Network ranges with mDNS reflector enabled |
| <a name="output_network_range_ids"></a> [network\_range\_ids](#output\_network\_range\_ids) | Map of network range IDs, keyed by subnet |
| <a name="output_network_range_names"></a> [network\_range\_names](#output\_network\_range\_names) | Map of network range names, keyed by subnet |
| <a name="output_network_ranges"></a> [network\_ranges](#output\_network\_ranges) | Map of all created network range resources, keyed by subnet |
| <a name="output_network_ranges_by_site"></a> [network\_ranges\_by\_site](#output\_network\_ranges\_by\_site) | Network ranges grouped by site ID |
| <a name="output_network_ranges_by_type"></a> [network\_ranges\_by\_type](#output\_network\_ranges\_by\_type) | Network ranges grouped by range type |
| <a name="output_processed_network_ranges"></a> [processed\_network\_ranges](#output\_processed\_network\_ranges) | The processed network range data from input (for debugging/verification) |
| <a name="output_ranges_by_interface"></a> [ranges\_by\_interface](#output\_ranges\_by\_interface) | Network ranges grouped by interface index |
| <a name="output_ranges_count_by_type"></a> [ranges\_count\_by\_type](#output\_ranges\_count\_by\_type) | Count of network ranges by type |
| <a name="output_raw_module_outputs"></a> [raw\_module\_outputs](#output\_raw\_module\_outputs) | Raw outputs from all network range submodules (for advanced use cases) |
| <a name="output_total_ranges_created"></a> [total\_ranges\_created](#output\_total\_ranges\_created) | Total number of network ranges created |
| <a name="output_translated_subnet_ranges"></a> [translated\_subnet\_ranges](#output\_translated\_subnet\_ranges) | Network ranges with NAT translation configured |
| <a name="output_vlan_ranges"></a> [vlan\_ranges](#output\_vlan\_ranges) | Network ranges configured with VLAN IDs |
<!-- END_TF_DOCS -->