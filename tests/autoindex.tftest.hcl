run "lists_no_directory_in_production" {
  command = plan

  module {
    source = "./tests/site"
  }

  variables {
    site = {
      debug = false
    }
  }

  assert {
    condition     = length(regexall("autoindex\\s+on", output.config)) == 0
    error_message = "Without debug, no location may list its directory (autoindex on)."
  }
}
