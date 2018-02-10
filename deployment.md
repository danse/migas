
here there are notes that can help for local or remote deployment

an old page with the previous version of crumbs can be kept running,
with the new one open in a different tab

in the `gh-pages` branch, it's necessary to commit dependencies in the
`bower_components` dir

also remove `pure.js` from `.gitignore`. There could be a commit in
gh-pages that already does that

the manifest needs to be updated, including remote dependencies like
libraries

#### what i typically do

- update the version in the manifest
- checkout to gh-page and rebase
- build Purescript assets
- force push

when switching back to master, it is necessary to run `bower install` again
