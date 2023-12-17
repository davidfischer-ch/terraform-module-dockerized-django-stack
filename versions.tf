terraform {
  required_version = ">= 1.6"

  required_providers {
    # https://github.com/kreuzwerker/terraform-provider-docker/tags
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.0.2"
    }

    jinja = {
      # https://github.com/NikolaLohinski/terraform-provider-jinja/tags
      source  = "NikolaLohinski/jinja"
      version = ">= 1.15.0"
    }

    local = {
      # https://github.com/hashicorp/terraform-provider-local/tags
      source  = "hashicorp/local"
      version = ">= 2.4.0"
    }

    null = {
      # https://github.com/hashicorp/terraform-provider-null/tags
      # TODO replace by "terraform_data"
      source  = "hashicorp/null"
      version = ">= 3.2.1"
    }

    random = {
      # https://github.com/hashicorp/terraform-provider-random/tags
      source  = "hashicorp/random"
      version = ">= 3.5.1"
    }
  }
}
