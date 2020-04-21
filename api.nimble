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

task rpi, "Building for a raspberry pi":
  exec "nim c -d:ssl src/api_raspberry.nim"
  exec "rsync src/api_raspberry pi@192.168.1.101:~/misc_api_nim"
