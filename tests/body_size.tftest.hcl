run "caps_every_request_body_with_spa" {
  command = plan

  module {
    source = "./tests/site"
  }

  variables {
    site = {
      max_body_size = "20M"
      websocket     = { path = "/ws/", read_timeout = "1h" }
      with_spa      = true
      django_paths  = ["i18n"]
    }
  }

  assert {
    condition = (
      length(regexall("client_max_body_size", output.config)) > 0 &&
      alltrue([
        for size in regexall("client_max_body_size\\s+(\\S+);", output.config) : size[0] == "20M"
      ])
    )
    error_message = "Every client_max_body_size must be the stack's max_body_size (20M)."
  }
}
