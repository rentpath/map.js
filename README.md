## Google Map API Wrapper
- pins
- clusters
- info window
- hood layers

## Getting started for development.

```
git checkout dev
git pull origin dev
git checkout -b my_branch
npm run preversion
```

## A basic red-green-refactor workflow.

```
npm install
npm run watch
npm run watch:test # in another terminal window or pane
```

## Examples of common tasks.

npm script commands are defined in the scripts section of `package.json`.
To see a full list of available npm commands, run:

```
npm run
```

### Install Node and Bower components.

```
npm install
```

### One-time compile of application source and tests.

```
npm run compile
```

### Compile application source & tests and build the distribution when files change.

```
npm run watch
```

### Running Tests.

One time.

```
npm test
```

Watch continuously and run tests when code or specs change.

```
npm run watch:test
```

### Cleaning

Remove `node_modules/` and `app/bower_components/`

```
npm run clean:all
```

Remove compiled `node_modules/` and `app/bower_components/`; reinstall
node modules and bower components; recompile code.

```
npm run reset
```

### Building a Distribution

To build a distribution and tag it, run one of the following commands.

```
npm version patch -m "Bumped to %s"
npm version minor -m "Bumped to %s"
npm version major -m "Bumped to %s"
```

There's a 'preversion' script in package.json that does the following:
  - Remove the `node_modules` and `app/bower_components` directories.
  - Install all npm and bower packages.
  - Compile the application source and specs.
  - Run the tests.
  - Remove the `dist/` directory and rebuild the distribution.

Just build a distribution.

```
npm run build
```

## Notes
  - The `dist/` directory must be part of the repo. Don't gitignore it!
