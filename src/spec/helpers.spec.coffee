_ = require 'underscore'
Promise = require 'bluebird'
Helpers = require '../lib/helpers'
fs = Promise.promisifyAll require('fs')

CREDENTIALS =
  key: '111'
  secret: 'secret'
  bucket: 'foo-bar'

describe 'Helpers', ->

  it 'should loadCredentials (given path)', (done) ->
    path = "#{__dirname}/../.s3-credentials-dummy.json"
    fs.writeFileAsync path, JSON.stringify(CREDENTIALS)
    .then ->
      credentials = Helpers.loadCredentials path
      expect(credentials.key).toBeDefined()
      expect(credentials.secret).toBeDefined()
      expect(credentials.bucket).toBeDefined()
      fs.unlinkAsync path
    .then -> done()
    .catch (error) -> done(error)

  _.each [
    "#{__dirname}/../.s3-credentials-dummy.json"
    "#{Helpers.userHome}/.s3-credentials.json"
  ], (path) ->
    it "should loadCredentials (#{path})", (done) ->
      fs.writeFileAsync path, JSON.stringify(CREDENTIALS)
      .then ->
        credentials = Helpers.loadCredentials()
        expect(credentials.key).toBeDefined()
        expect(credentials.secret).toBeDefined()
        expect(credentials.bucket).toBeDefined()
        fs.unlinkAsync path
      .then -> done()
      .catch (error) -> done(error)


  it 'should parseJsonFromFile', ->
    config = Helpers.parseJsonFromFile "#{__dirname}/../examples/descriptions.json"
    expect(config).toBeDefined()
    expect(config.length).toBe 2
    expect(config[0].formats.length).toBe 5
    expect(config[0].prefix).toBe 'products/'
    expect(config[1].formats.length).toBe 2
    expect(config[1].prefix).toBe 'looks/'

  it 'should throw if file cannot be found', ->
    spyOn(Helpers, '_lookupPath').andReturn undefined
    expect(-> Helpers.loadCredentials 'foo').toThrow new Error 'Missing S3 credentials'

  it 'should throw if json cannot be parsed', ->
    wrongFile = "#{__dirname}/../README.md"
    expect(-> Helpers.parseJsonFromFile wrongFile).toThrow new Error "Error parsing JSON for file '#{wrongFile}'"
