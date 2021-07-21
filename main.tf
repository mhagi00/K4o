resource "mongodbatlas_project" "atlas" {
  name   = var.project_name
  org_id = var.org_id
}

data "mongodbatlas_clusters" "this" {
  project_id = mongdbatlas_project.atlas.id
}

data "mongodbatlas_cluster" "this" {
  for_each = toset(data.mongodbatlas_clusters.this.results[*].name)

  project_id = mongdbatlas_project.atlas.id
  name       = each.value
}

resource "random_password" "store-service-password" {
  # Generate a unique new password for the DB user
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "mongodbatlas_database_user" "store-service-user" {
  # create a username for the service (e.g. the service name)
  username = "${var.environment}-${each.key}"

  # create a password for the service 
  password = random_password.store-service-password.result

  # Create the right role (read only permissions) for this user and service
  dynamic "roles" {
    for_each = each.value.mongoCollection[*]
    content {
      role_name       = "read"
      database_name   = each.value.mongoDatabase
      collection_name = roles.value
    }
  }
}

# output "atlasclusterstring" {
#   value = mongodbatlas_cluster.cluster-atlas.connection_strings
# }

# output connection_strings {
#         value = lookup(mongodbatlas_cluster.this.connection_strings.0.standard_srv)
