# Package

version       = "0.1.0"
author        = "Jeremy Savor"
description   = "API for cool stuff"
license       = "MIT"
srcDir        = "src"
bin           = @["api"]

# backend       = "c"

# Dependencies

requires "nim >= 1.0.6", "jester"

task serve, "Run the API server":
    exec "nimble run -d:ssl api.nimble"
