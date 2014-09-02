![SPHERE.IO icon](https://admin.sphere.io/assets/images/sphere_logo_rgb_long.png)

# s3utils

[![Build Status](https://secure.travis-ci.org/sphereio/node-s3-utils.png?branch=master)](http://travis-ci.org/sphereio/node-s3-utils) [![Coverage Status](https://coveralls.io/repos/sphereio/node-s3-utils/badge.png)](https://coveralls.io/r/sphereio/node-s3-utils) [![Dependency Status](https://david-dm.org/sphereio/node-s3-utils.png?theme=shields.io)](https://david-dm.org/sphereio/node-s3-utils) [![devDependency Status](https://david-dm.org/sphereio/node-s3-utils/dev-status.png?theme=shields.io)](https://david-dm.org/sphereio/node-s3-utils#info=devDependencies)


A Command Line Interface holding some utilities for managing AWS resources (e.g. converting/resizing images stored in S3 folders). It uses [knox](https://github.com/LearnBoost/knox) as S3 client.

## Getting Started
Install the module

```bash
$ npm install -g node-s3-utils
```

Install `imagemagic` (used for [image conversion](#images-convert))

```bash
$ apt-get install imagemagick

# or (osx)
$ brew install imagemagick

# or download installer http://cactuslab.com/imagemagick/
```

Create a credentials file (JSON) required for accessing AWS resources:

```bash
$ ./create_credentials.sh
```

Example:

```json
{
   "aws_key": "1111111",
   "aws_secret": "3333333",
   "aws_bucket": "s3-bucket-name"
}
```

## Documentation
The module is a CLI tool.
To get some information just call help

```bash
$ s3utils help
```

The module exposes 2 main commands

- `files`
- `images`

### Subcommands

#### `files`
Handle files resources in S3 buckets

```bash
$ s3utils help files
```

Available sucommands are
- `upload` - Uploads a given file to a given bucket
- `delete` - Deletes one-to-many files matching a (bucket) `prefix` and a `regex` to filter listed files from bucket

#### `files upload`
Upload one file to a given bucket

```bash
$ s3utils files help upload
```

Options:
- `credentials <path>` - Required
- `source <path>` - Required
- `target <path>` - Required

##### Example
```bash
$ s3utils files upload -c ./credentials.json -s ./bar.txt -t foo/bar.txt
```

#### `files delete`
Delete one-to-many files in S3 buckets

```bash
$ s3utils files help delete
```

Options:
- `credentials <path>` - Required
- `prefix <name>` - Required
- `regex [name]` - Optional

##### Example
```bash
# delete all files with `foo/` prefix, filtered by `.txt`
$ s3utils files delete -c ./credentials.json -p foo/ -r 'foo\/(\w)+\.txt'
```

#### `images`
Handle images resources in S3 buckets

```bash
$ s3utils help images
```

Available sucommands are
- `convert` - Handles converting/resizing images from a bucket

#### `images convert`

> Requires `imagemagick` to be installed

Subsequently downloads images from S3 source folders, converts to defined image sizes and uploads resulting files to proper target folders

```bash
$ s3utils images help convert
```

Options:
- `credentials <path>` - Required
- `descriptions <path>` - Required

The `descriptions` object defines which AWS S3 folders are used and which image sizes have to be generated.

> A conversion description has to be defined in the configuration file for each of the image folder in S3 that needs to be processed


##### Example
Converts two S3 folders (`products/unprocessed` and `looks/unprocessed`), meaning all images in those folders will be downloaded, converted/resized and uploaded to a target folder.

```javascript
// descriptions.json
[
  {
    "prefix_unprocessed": "products/unprocessed", // source S3 path within bucket
    "prefix_processed": "products/processed", // target S3 path within bucket
    "prefix": "products/", // target S3 path within a bucket for resized images
    "headers": { // headers used for querying content list from S3
      "max-keys": 3000 // number of elements return from AWS list query (default is 1000)
    },
    "formats": [ // image sizes to upload to S3
      {
        "suffix": "_thumbnail", // will be appended to the file name
        "width": 240, // width for resized image
        "height": 240 // height for resized image
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

```bash
$ s3utils images convert -c ./credentials.json -d ./descriptions.json
```

### Development in a VM with Vagrant
We provide also a simple `Vagrantfile` setup to run it locally in a little VM. All required tools will be automatically installed once the box is provisioned.

```bash
$ vagrant up
```

## Tests
Tests are written using [jasmine](http://pivotal.github.io/jasmine/) (Behavior-Driven Development framework for testing javascript code). Thanks to [jasmine-node](https://github.com/mhevery/jasmine-node), this test framework is also available for Node.js.

To run tests, simple execute the *test* task using `grunt`.

```bash
$ grunt test
```

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
