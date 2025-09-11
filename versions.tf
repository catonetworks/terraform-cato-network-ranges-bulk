terraform {
  required_providers {
    cato = {
      # source = "catonetworks/cato"
      source  = "terraform-providers/cato"
      version = "0.0.43"
    }
  }
  required_version = ">= 0.13"
}
