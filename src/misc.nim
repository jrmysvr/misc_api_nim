import times
import httpClient
import htmlgen
import strutils
import json
import streams
import os
import strformat

# Pass API Key to api.nasa.gov as command line argument

proc getAPOD(key: TaintedString): JsonNode =
  let
    url = "https://api.nasa.gov/planetary/apod?api_key=$1".format(key)
    # fetch today's photo
    client = newHttpClient()
    resp = client.get(url)
    jsonResp = parseJson(resp.body())

  jsonResp

proc saveToFile(fileName: string, stuff: string) =
  var strm = newFileStream(fileName, fmWrite)
  strm.writeLine(stuff)
  strm.close()

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

proc fetchAPOD(key: TaintedString) : string =
  ## Fetch the Astronomy Picture of the Day url
  let
    today = parse(now().format(dateFormat), dateFormat)
    fetched = today == fetchDate

  if not fetched:
    fetchDate = today
    let
      jsonResp = getAPOD(key)
      fileName = "APOD_$1.json".format(jsonResp["date"]
                                       .getStr()
                                       .strip(chars = {'\"'}))

    fnameToday = fileName

    saveJson(fnameToday, jsonResp)
    let url = jsonResp["hdurl"].getStr()
    apodURL = if url.isEmptyOrWhitespace(): jsonResp["url"].getStr() else: url

  result = apodURL

proc getAPODexplanation(key: TaintedString) : string =
  ## Get the explanation text of the Astronomy Picture of the Day

  let
    today = parse(now().format(dateFormat), dateFormat)
    fetched = today == fetchDate

  if not fetched:
    discard fetchAPOD(key)

  result = openJson(fnameToday)["explanation"].getStr()

proc apodPage*(key: TaintedString) : string =
  let
    url = fetchAPOD(key)
    explanation = getAPODexplanation(key)

  result = html(title("Astronomy Picture of the Day"),
                body(
                  img(src = url,
                      alt = explanation,
                      style = "display: block; margin-left: auto; margin-right: auto;",
                  ),
                  p(explanation),
                )
          )

proc variablesPage*() : string =
  result = html(body(
                  p(fmt"APOD URL: {apodURL}"),
                  p(fmt"FETCH DATE: {fetchDate}"),
                  p(fmt"FNAME TODAY: {fnameToday}"),
               )
           )

proc getJokeOfTheDay() : string =
  let
    url = "https://api.jokes.one/jod"
    client = newHttpClient()
    resp = client.get(url)
    jsonResp = parseJson(resp.body())
    success = jsonResp["success"]
    contents = jsonResp["contents"]
    joke = contents["jokes"][0]["joke"]["text"].getStr()

  echo success
  echo contents
  result = joke.replace("\r\n", "\n")

proc jokePage*() : string =
  result = html(body(
                  p(fmt"The Joke of The Day: "),
                  p(getJokeOfTheDay()),
                  p("Credit: jokes.one")
               )
           )
