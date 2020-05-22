import jester
import os

import misc

# Pass API Key to api.nasa.gov as command line argument
let KEY = paramStr(1)

routes:
  get "/api/apod":
    resp apodPage(KEY)

  get "/api/joke":
    resp jokePage()

  get "/api/variables":
    resp variablesPage()
