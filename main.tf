resource "mongodbatlas_project" "this" {
  name   = var.project_name
  org_id = var.org_id
}

data "mongodbatlas_clusters" "this" {
  project_id = mongdbatlas_project.this.id
}

data "mongodbatlas_cluster" "this" {
  for_each = toset(data.mongodbatlas_clusters.this.results[*].name)

  project_id = mongdbatlas_project.this.id
  name       = each.value
}

data "local_file" "getfile" {
  filename = "${path.module}/data.json"
}

locals {
  configfile = jsondecode(data.local_file.getfile.content)
}

#   connection_strings = {
#     for svc in var.service_configuration :
#     # your code magic here to construct the correct connection string based on the following convention mongodb+srv://[username]:[password]@[cluster]/[db]/[collection]
#   }
# }

resource "random_password" "store-service-password" {
  # Generate a unique new password for the DB user
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "mongodbatlas_database_user" "store-service-user" {
  # create a username for the service (e.g. the service name)
  username = var.environment

  # create a password for the service 
  password = random_password.store-service-password.result

  # Create the right role (read only permissions) for this user and service
  dynamic "roles" {
    for_each = local.configfile.service_configuration
    content {
      role_name       = "read"
      database_name   = roles.value.mongoDatabase
      collection_name = roles.value.mongoCollection
    }
  }
}

# output "atlasclusterstring" {
#   value = mongodbatlas_cluster.cluster-atlas.connection_strings
# }

# output connection_strings {
#         value = lookup(mongodbatlas_cluster.this.connection_strings.0.standard_srv)

output "connection" {
  value = [
    for s in toset(local.configfile.service_configuration) : s
  ]
}
