An old page with the previous version of Crumbs can be kept running,
with the new one open in a different tab.

In the `gh-pages` branch, it's necessary to commit dependencies in the
`bower_components` dir.

Also remove `pure.js` from `.gitignore`.

The manifest needs to be updated, including remote dependencies like
libraries.

#### What i typically do

- update the version in the manifest
- checkout to gh-page and rebase
- build Purescript assets
- force push

When switching back to master, it is necessary to run `bower install` again