program = require 'commander'

program
.command 'convert', 'Convert images'
.parse process.argv

program.help() unless program.args.length
