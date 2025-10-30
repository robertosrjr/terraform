variable "subscription_id" {
  description = "ID da assinatura Azure alvo."
  type        = string
  #default     = "SEU_ID_DA_SUBSCRIPTION_AZURE" # Substitua pelo seu ID ou remova para usar o default do provedor
}

variable "location" {
  description = "Localização (região) padrão do Azure para os recursos."
  type        = string
  #default     = "eastus" # Exemplo de região padrão
}

variable "environment" {
  description = "Nome do ambiente (ex: dev, stg, prd)."
  type        = string
  #default     = "dev"
}

variable "resource_group_name_prefix" {
  description = "Prefixo para os nomes dos Grupos de Recursos."
  type        = string
  #default     = "minha-app"
}

variable "project_name" {
  description = "Prefixo para os nomes dos Grupos de Recursos."
  type        = string
  #default     = "minha-app"
}