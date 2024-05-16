plugin "terraform" {
    enabled = true
    version = "0.2.2"
    source  = "github.com/terraform-linters/tflint-ruleset-terraform"
}

plugin "azurerm"{
    enabled = true
    version = "0.26.0"
    source = "github.com/terraform-linters/tflint-ruleset-azurerm"
}
