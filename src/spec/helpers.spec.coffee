Helpers = require '../lib/helpers'

describe 'Helpers', ->

  it 'should loadConfig', ->
    config = Helpers.loadConfig "#{__dirname}/../examples/descriptions.json"

    expect(config).toBeDefined()
    expect(config.length).toBe 2
    expect(config[0].formats.length).toBe 5
    expect(config[0].prefix).toBe 'products/'
    expect(config[1].formats.length).toBe 2
    expect(config[1].prefix).toBe 'looks/'

  it 'should throw if config file cannot be found', ->
    expect(-> Helpers.loadConfig 'foo').toThrow new Error 'ENOENT, no such file or directory \'foo\''

  it 'should throw if config file cannot be parsed', ->
    wrongFile = "#{__dirname}/../README.md"
    expect(-> Helpers.loadConfig wrongFile).toThrow new Error "Error parsing JSON for file '#{wrongFile}'"