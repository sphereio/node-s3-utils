debug = require('debug')('s3utils')
colors = require 'colors'
program = require 'commander'
pkginfo = require('pkginfo')(module, 'version')
Helpers = require './helpers'

program
.version module.exports.version
.command 'files', 'File commands'
.command 'images', 'Image commands'
.parse process.argv

program.on '--help', Helpers.logo

debug 'parsing args: %s', process.argv

program.help() unless program.args.length
