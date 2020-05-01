import jester
import times
import httpClient
import htmlgen
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

proc openJson(fileName: string) : JsonNode =
  var strm = newFileStream(fileName, fmRead)
  result = parseJson(strm)
  strm.close()

proc defaultURL() : string =
  var
    defaultURLFile = "URL.txt"
    strm = newFileStream(defaultURLFile, fmRead)

  discard strm.readLine(result)


# APOD endpoint
const dateFormat = "yyyy-MM-dd"
var
  apodURL = defaultURL()
  fetchDate = now() - 1.years
  fnameToday = ""

proc fetchAPOD() : string =
  ## Fetch the Astronomy Picture of the Day url
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

    fnameToday = fileName

    saveJson(fnameToday, jsonResp)
    let url = jsonResp["hdurl"].getStr()
    apodURL = if url.isEmptyOrWhitespace(): jsonResp["url"].getStr() else: url

  result = apodURL

proc getAPODexplanation() : string =
  ## Get the explanation text of the Astronomy Picture of the Day

  let
    today = parse(now().format(dateFormat), dateFormat)
    fetched = today == fetchDate

  if not fetched:
    discard fetchAPOD()

  result = openJson(fnameToday)["explanation"].getStr()

proc apodPage() : string =
  let
    url = fetchAPOD()
    explanation = getAPODexplanation()

  result = html(title("Astronomy Picture of the Day"),
                body(
                  img(src = url,
                      alt = explanation,
                      style = "display: block; margin-left: auto; margin-right: auto;",
                  ),
                  p(explanation),
                )
          )

settings:
  port = Port(5001)

routes:
  get "/api/apod":
    resp apodPage()

  get "/api":
    resp "I'm a Raspberry Pi"

