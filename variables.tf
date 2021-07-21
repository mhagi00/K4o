
variable "public_key" {
  description = "The public API key for MongoDB Atlas"
  default = "12345"
}
variable "private_key" {
  description = "The private API key for MongoDB Atlas"
  default     = "12345"
  type = string
}

variable "project_name" {
  description = "The name of the project you want to create"
  type        = string
  default     = "projectname"
}

variable "org_id" {
  description = "The ID of the Atlas organization you want to create the project within"
  type        = string
  default = "org"
}

variable "mongdbatlas_project_id" {
  description = "Project ID"
  default = "projectid"
}

variable "environment" {
  description = "username"
  type        = list(string)
  default     = ["possums-data-store", "numbats-data-store", "marsupial-data-store"]
}
 
