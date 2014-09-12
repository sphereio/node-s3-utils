debug = require('debug')('s3utils')
program = require 'commander'
pkginfo = require('pkginfo')(module, 'version')

program
.version module.exports.version
.command 'files', 'File commands'
.command 'images', 'Image commands'
.parse process.argv

debug 'parsing args: %s', process.argv

program.help() unless program.args.length
