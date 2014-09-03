fs = require 'fs'
_ = require 'underscore'

# user home path '~/'
ROOT = process.env.HOME or process.env.HOMEPATH or process.env.USERPROFILE

class Helpers

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
  @loadCredentials: (argPath) ->
    key = process.env.S3_KEY
    secret = process.env.S3_SECRET
    bucket = process.env.S3_BUCKET
    if key and secret and bucket
      key: key
      secret: secret
      bucket: bucket
    else
      existingPath = _.find [
        argPath,
        "./.s3-credentials.json",
        "#{ROOT}/.s3-credentials.json",
        '/etc/.s3-credentials.json'
      ], (path) ->
        fs.existsSync path
      if existingPath
        @parseJsonFromFile existingPath
      else
        throw new Error 'Missing S3 credentials'

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
      throw new Error "Error parsing JSON for file '#{existingPath}'"

module.exports = Helpers
