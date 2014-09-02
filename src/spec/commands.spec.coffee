Promise = require 'bluebird'
execAsync = Promise.promisify(require('child_process').exec)

CMD_PATH = "#{__dirname}/../bin/s3utils"

describe 's3utils', ->

  it 'should show help', (done) ->
    execAsync CMD_PATH
    .then (result) ->
      expect(result).toMatch /Usage\: s3utils \[options\] \[command\]/
      done()
    .catch (e) -> done(e)


  describe ':: images', ->

    it 'should show help', (done) ->
      execAsync "#{CMD_PATH} images"
      .then (result) ->
        expect(result).toMatch /Usage\: s3utils-images \[options\] \[command\]/
        done()
      .catch (e) -> done(e)


    describe ':: convert', ->

      it 'should show help', (done) ->
        execAsync "#{CMD_PATH} images convert"
        .then (result) ->
          expect(result).toMatch /Missing required arguments/
          expect(result).toMatch /Usage\: s3utils-images-convert \[options\]/
          done()
        .catch (e) -> done(e)
