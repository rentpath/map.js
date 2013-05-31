preserves
=========

js source files for jam server

See [JAM.md in the idg repo](https://github.com/primedia/idg/blob/master/JAM.md) for instructions on setup and creating a package.

When creating a new package, checkout the `template` branch and create a branch named the same as your new package off of it:

````
git checkout template
git checkout -B [package name]
````

Feature branches for a package should be based off of that package's branch. For example, to create a feature branch for a package named "foo":

````
git checkout foo
git checkout -B some_feature_branch_name
````

Any changes made to a package must be noted by bumping the version in the `package.json` in accordance with [semantic versioning](http://semver.org) on the package's branch (not in the master branch!). If checking out the package's branch doesn't work using 'git checkout [package name], then do the following:

````
git checkout --track -b [package name] origin/[package name]
````

Then the branch can be merged into master, tagged, and the package published to the Jam server as documented in [JAM.md](https://github.com/primedia/idg/blob/master/JAM.md).
