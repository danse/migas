{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "crumbs"
, dependencies =
  [ "console"
  , "effect"
  , "lists"
  , "ordered-collections"
  , "psci-support"
  , "quickcheck"
  , "smolder"
  , "stringutils"
  , "test-unit"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
