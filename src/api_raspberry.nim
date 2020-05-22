import jester
import os
import misc

# Pass API Key to api.nasa.gov as command line argument
let KEY = paramStr(1)

settings:
  port = Port(5001)

routes:
  get "/api/apod":
    resp apodPage(KEY)

  get "/api/variables":
    resp variablesPage()

  get "/api":
    resp "I'm a Raspberry Pi"

  get "/api/joke":
    resp jokePage()
