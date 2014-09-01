# s3-utils

[![Build Status](https://secure.travis-ci.org/sphereio/node-s3-utils.png?branch=master)](http://travis-ci.org/sphereio/node-s3-utils) [![Coverage Status](https://coveralls.io/repos/sphereio/node-s3-utils/badge.png)](https://coveralls.io/r/sphereio/node-s3-utils) [![Dependency Status](https://david-dm.org/sphereio/node-s3-utils.png?theme=shields.io)](https://david-dm.org/sphereio/node-s3-utils) [![devDependency Status](https://david-dm.org/sphereio/node-s3-utils/dev-status.png?theme=shields.io)](https://david-dm.org/sphereio/node-s3-utils#info=devDependencies)


Utilities used for handling AWS resources (e.g. converting/resizing images stored in S3 folders).

## Getting Started
Install the module 

```bash
npm install s3-utils
```

Install imagemagic (used for image conversion)

```bash
apt-get install imagemagick
```

Create a credentials file (JSON) required for accessing AWS resources:
- object `credentials` - AWS credentials
- string `aws_key` -  AWS key
- string `aws_secret` - AWS secret
- string `aws_bucket` - S3 bucket folder

Example:

```json
{
   "aws_key": "1111111",
   "aws_secret": "3333333",
   "aws_bucket": "s3-bucket-name"
}
```

## Documentation

Show available subcommands:

```bash
$ node lib/s3utils help

  Usage: s3utils [options] [command]

  Commands:

    images
       Image commands

    help [cmd]
       display help for [cmd]


  Options:

    -h, --help     output usage information
    -V, --version  output the version number
```

### Subcommands

Show available subcommands for `image` command:

```bash
$ s3utils help images

  Usage: s3utils-images [options] [command]

  Commands:

    convert
       Convert images

    help [cmd]
       display help for [cmd]


  Options:

    -h, --help  output usage information
```

#### Convert

Subsequently downloads, converts and uploads resized images.


##### Help

Show available options for `convert` command:

```bash
$ s3utils images help convert

  Usage: s3utils-images-convert [options]

  Options:

    -h, --help                 output usage information
    -c, --credentials <path>   set aws credentials file path
    -d, --descriptions <path>  set image descriptions file path
```

##### Descriptions

For each to be processed image folder in AWS S3, a conversion description has to be defined within a JSON configuration file (see option `--descriptions`).

The descriptions object defines which AWS S3 folders are used and which image sizes have to be generated.

- object[] descriptions - S3 image conversion settings
  - string `prefix_unprocessed` - source S3 path within a bucket
  - string `prefix_processed` - target S3 path within a bucket
  - string `prefix` - target S3 path within a bucket for resized images
  - object `header` - headers used for querying content list from S3
    - integer `max-keys` - number of elements return from AWS list query (default is 1000)
  - object[] `formats` - image sizes to upload to S3
    - string `suffix` - will be appended to the file name
    - integer `width` - width for resized image
    - integer `height` - height for resized image

Example:

Convert two S3 folders ("products/unprocessed" and "looks/unprocessed").

```json
[
  {
    "prefix_unprocessed": "products/unprocessed",
    "prefix_processed": "products/processed",
    "prefix": "products/",
    "headers": {
      "max-keys": 3000
    },
    "formats": [
      {
        "suffix": "_thumbnail",
        "width": 240,
        "height": 240
      },
      {
        "suffix": "_small",
        "width": 350,
        "height": 440
      }
    ]
  },
  {
    "prefix_unprocessed": "looks/unprocessed",
    "prefix_processed": "looks/processed",
    "prefix": "looks/",
    "headers": {
      "max-keys": 3000
    },
    "formats": [
      {
        "suffix": "_thumbnail",
        "width": 240,
        "height": 240
      }
    ]
  }
]
```

##### Example

```bash
$ s3utils images convert -c ./credentials.json -d ./descriptions.json
```

## Tests
Tests are written using [jasmine](http://pivotal.github.io/jasmine/) (Behavior-Driven Development framework for testing javascript code). Thanks to [jasmine-node](https://github.com/mhevery/jasmine-node), this test framework is also available for Node.js.

To run tests, simple execute the *test* task using `grunt`.

```bash
$ grunt test
```

## Examples
_(Coming soon)_

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).
More info [here](CONTRIBUTING.md)

## Releasing
Releasing a new version is completely automated using the Grunt task `grunt release`.

```javascript
grunt release // patch release
grunt release:minor // minor release
grunt release:major // major release
```

## Styleguide
We <3 CoffeeScript here at commercetools! So please have a look at this referenced [coffeescript styleguide](https://github.com/polarmobile/coffeescript-style-guide) when doing changes to the code.

## License
Copyright (c) 2014 Sven Mueller
Licensed under the MIT license.
