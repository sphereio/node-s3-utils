debug = require('debug')('s3utils-helpers')
fs = require 'fs'
_ = require 'underscore'
colors = require 'colors'
{CustomError} = require './errors'

class Helpers

  # user home path '~/'
  @userHome: process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE

  @logo: ->
    console.log "      ____       __                             __         ___  ".white
    console.log "     /\\  _`\\   /'__`\\                          /\\ \\__  __ /\\_ \\  ".white
    console.log "     \\ \\,\\L\\_\\/\\_\\L\\ \\                   __  __\\ \\ ,_\\/\\_\\\\//\\ \\     ____  ".white
    console.log "      \\/_\\__ \\\\/_/_\\_<_      _______    /\\ \\/\\ \\\\ \\ \\/\\/\\ \\ \\ \\ \\   /',__\\  ".white
    console.log "        /\\ \\L\\ \\/\\ \\L\\ \\    /\\______\\   \\ \\ \\_\\ \\\\ \\ \\_\\ \\ \\ \\_\\ \\_/\\__, `\\  ".white
    console.log "        \\ `\\____\\ \\____/    \\/______/    \\ \\____/ \\ \\__\\\\ \\_\\/\\____\\/\\____/  ".white
    console.log "         \\/_____/\\/___/                   \\/___/   \\/__/ \\/_/\\/____/\\/___/  ".white

  ###*
   * @static
   * Lookup S3 credentials from different locations and return parsed JSON
   * - ENV variables
   * - argument option
   * - default system location
   *   - ~/.s3-credentials.json
   *   - /etc/.s3-credentials.json
   *
   * @param  {String} argPath An optional path passed as command option
   * @return {Object} The S3 credentials
   * @throws {Error} If file is not found in any of the locations
  ###
  @loadCredentials: (argPath) =>
    debug 'loading credentials (given arg path: %s)', argPath
    key = process.env.S3_KEY
    secret = process.env.S3_SECRET
    bucket = process.env.S3_BUCKET
    if key and secret and bucket
      key: key
      secret: secret
      bucket: bucket
    else
      existingPath = @_lookupPath argPath
      debug 'path for credentials %s', existingPath
      if existingPath
        @parseJsonFromFile existingPath
      else
        throw new CustomError 'Missing S3 credentials'

  @_lookupPath: (argPath) =>
    _.find [
      argPath,
      "./.s3-credentials.json",
      "#{@userHome}/.s3-credentials.json",
      '/etc/.s3-credentials.json'
    ], (path) -> fs.existsSync path

  ###*
   * @static
   * Tries to parse a JSON by reading file content from given path
   * @param  {String} path The location where to read the file
   * @return {Object} The parsed JSON
   * @throws {Error} If file content cannot be parsed
  ###
  @parseJsonFromFile: (path) ->
    data = fs.readFileSync path, encoding: 'utf-8'
    try
      JSON.parse data
    catch e
      throw new CustomError "Error parsing JSON for file '#{path}'"

module.exports = Helpers
