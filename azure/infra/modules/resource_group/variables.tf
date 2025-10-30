
variable "location" {
  description = "Localização (região) padrão do Azure para os recursos."
  type        = string
}

variable "environment" {
  description = "Nome do ambiente (ex: dev, stg, prd)."
  type        = string
}

variable "project_name" {
  description = "Prefixo para os nomes dos Grupos de Recursos."
  type        = string
}