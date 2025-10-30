# Bloco de configuração do Terraform
# Define a versão mínima do Terraform e os provedores necessários.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
  }
}

# Bloco de configuração do provedor Azure
# Define as configurações globais para o provedor Azure.
# O bloco 'features {}' é obrigatório para o provedor azurerm.
provider "azurerm" {
    features {}
    # A autenticação será buscada automaticamente do seu ambiente (Azure CLI, variáveis de ambiente, etc.)
    # Se você tiver múltiplas subscriptions, pode especificar aqui:
    resource_provider_registrations = "none" # This is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  
}