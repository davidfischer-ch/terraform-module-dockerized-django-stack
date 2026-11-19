run "serves_spa_files_with_the_server_headers" {
  command = plan

  module {
    source = "./tests/site"
  }

  variables {
    site = {
      with_spa     = true
      django_paths = []
    }
  }

  # A location defining an add_header of its own inherits none of the server's security headers.
  assert {
    condition = (
      length(regexall("location /assets/ \\{[^}]*\\}", output.config)) == 1 &&
      length(regexall("location / \\{[^}]*\\}", output.config)) == 1 &&
      length(regexall("add_header", join("", concat(
        regexall("location /assets/ \\{[^}]*\\}", output.config),
        regexall("location / \\{[^}]*\\}", output.config),
      )))) == 0
    )
    error_message = "The SPA's static locations must not define an add_header of their own."
  }
}
