# s3-image-utils

[![Build Status](https://secure.travis-ci.org/sphereio/s3-image-utils.png?branch=master)](http://travis-ci.org/sphereio/s3-image-utils) [![Coverage Status](https://coveralls.io/repos/sphereio/s3-image-utils/badge.png)](https://coveralls.io/r/sphereio/s3-image-utils) [![Dependency Status](https://david-dm.org/sphereio/s3-image-utils.png?theme=shields.io)](https://david-dm.org/sphereio/s3-image-utils) [![devDependency Status](https://david-dm.org/sphereio/s3-image-utils/dev-status.png?theme=shields.io)](https://david-dm.org/sphereio/s3-image-utils#info=devDependencies)


Utilities for processing AWS S3 images.

## Getting Started
Install the module with: `npm install s3-image-utils`


## Documentation
_(Coming soon)_

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
