module Test.Main where

import Prelude
import Test.Unit (suite, test)
import Test.Unit.Main (runTest)
import Test.Unit.Assert as Assert
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Test.Unit.Console (TESTOUTPUT)
import Control.Monad.Aff.AVar (AVAR)
import Main (getTags)

main :: forall e. Eff (
  console :: CONSOLE,
  testOutput :: TESTOUTPUT,
  avar :: AVAR            
   | e) Unit                      
main = runTest do
  suite "getTags" do
    test "parses hashtags" do
      Assert.equal ["simple"] (getTags "a #simple one")
      Assert.equal ["multiple", "ones"] (getTags "#multiple #ones")
      Assert.equal ["comma"] (getTags "with #comma, right")
      Assert.equal ["dash-now"] (getTags "with #dash-now right")
      Assert.equal ["thrashwithin"] (getTags "any #thrash#within a word")
    test "ignores a single hash" do
      Assert.equal [] (getTags "nothing # here")
