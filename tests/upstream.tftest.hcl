run "resolves_the_web_container_per_request" {
  command = plan

  module {
    source = "./tests/site"
  }

  variables {
    site = {
      websocket    = { path = "/ws/", read_timeout = "1h" }
      with_spa     = true
      django_paths = ["i18n"]
    }
  }

  # A name in an upstream block is resolved once, when nginx starts: a recreated web container on
  # another address is then unreachable until nginx restarts.
  assert {
    condition = (
      strcontains(output.config, "resolver 127.0.0.11 ") &&
      length(regexall("proxy_pass\\s+\\S+;", output.config)) == 4 &&
      alltrue([
        for target in regexall("proxy_pass\\s+(\\S+);", output.config) : startswith(target[0], "$")
      ])
    )
    error_message = join(" ", [
      "Every proxy_pass must name the web container through a variable,",
      "resolved by Docker's DNS.",
    ])
  }
}

run "proxies_without_spa_through_the_resolver" {
  command = plan

  module {
    source = "./tests/site"
  }

  assert {
    condition = (
      strcontains(output.config, "resolver 127.0.0.11 ") &&
      length(regexall("proxy_pass\\s+\\$\\S+;", output.config)) == 1
    )
    error_message = join(" ", [
      "The single location / must proxy through the variable,",
      "resolved by Docker's DNS.",
    ])
  }
}
