import jester
import times
import httpClient
import strutils
import json
import streams
import os

# Pass API Key to api.nasa.gov as command line argument
let KEY = paramStr(1)

proc getAPOD(): JsonNode =
  let
    url = "https://api.nasa.gov/planetary/apod?api_key=$1".format(KEY)
    # fetch today's photo
    client = newHttpClient()
    resp = client.get(url)
    jsonResp = parseJson(resp.body())

  jsonResp

proc saveJson(fileName: string, obj: JsonNode) =
  var strm = newFileStream(fileName, fmWrite)
  strm.writeLine(obj)
  strm.close()

# APOD endpoint
const dateFormat = "yyyy-MM-dd"
var
  apodURL = ""
  fetchDate = now() - 1.years

routes:
  get "/api/apod":
    let
      today = parse(now().format(dateFormat), dateFormat)
      fetched = today == fetchDate
    if not fetched:
      fetchDate = today
      let
        jsonResp = getAPOD()
        fileName = "APOD_$1.json".format(jsonResp["date"]
                                         .getStr()
                                         .strip(chars = {'\"'}))

      saveJson(fileName, jsonResp)
      apodURL = $jsonResp["hdurl"].getStr()

    redirect apodURL

