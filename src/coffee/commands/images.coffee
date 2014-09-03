program = require 'commander'
Helpers = require '../helpers'

program
.command 'convert', 'Convert images'
.parse process.argv

program.on '--help', Helpers.logo

program.help() unless program.args.length
