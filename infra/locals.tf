locals {
  context = {
    default = {
      environment = "development"
    }

    development = {
      environment = "development"
    }

    production = {
      environment = "production"
    }
  }

  reports_bucket_name = "reports"
  environment         = local.context[terraform.workspace].environment
}
