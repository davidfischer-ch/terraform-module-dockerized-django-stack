terraform {
  required_version = ">= 1.6"

  required_providers {
    # https://github.com/vancluever/terraform-provider-acme/tags
    acme = {
      source  = "vancluever/acme"
      version = ">= 2.21.0"
    }

    # https://github.com/hashicorp/terraform-provider-aws/tags
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }

    # https://github.com/kreuzwerker/terraform-provider-docker/tags
    docker = {
      source  = "kreuzwerker/docker"
      version = ">= 3.0.2"
    }

    # https://github.com/hashicorp/terraform-provider-external/tags
    external = {
      source  = "hashicorp/external"
      version = ">= 2.3.0"
    }

    # https://github.com/NikolaLohinski/terraform-provider-jinja/tags
    jinja = {
      source  = "NikolaLohinski/jinja"
      version = ">= 1.17.0"
    }

    # https://github.com/hashicorp/terraform-provider-local/tags
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.1"
    }

    # https://github.com/hashicorp/terraform-provider-null/tags
    null = {
      source  = "hashicorp/null"
      version = ">= 3.2.2"
    }

    # https://github.com/hashicorp/terraform-provider-random/tags
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }
}

provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}
