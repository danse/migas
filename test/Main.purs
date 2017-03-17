module Test.Main where

import Prelude
import Test.Unit (suite, test)
import Test.Unit.Main (runTest)
import Test.Unit.Assert as Assert
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Eff.Random (RANDOM)
import Test.Unit.Console (TESTOUTPUT)
import Control.Monad.Aff.AVar (AVAR)
import Test.QuickCheck (quickCheck)
import Data.Tuple (fst, snd)
import Data.String (length)
import Main (crumbify, getTags)

crumbify1 :: String -> Int -> Boolean
crumbify1 desc minutes = 
  minutes == length returned
  where returned = fst $ crumbify desc minutes

crumbify2 :: String -> Int -> Boolean
crumbify2 desc minutes = (length rest) <= ((length desc) - minutes)
  where rest = snd $ crumbify desc minutes

main :: forall e. Eff (
  console :: CONSOLE,
  testOutput :: TESTOUTPUT,
  avar :: AVAR,            
  err :: EXCEPTION,
  random :: RANDOM
   | e) Unit                      
main = do
  runTest $ do
    suite "getTags" do
      test "parses hashtags" do
        Assert.equal ["simple"] (getTags "a #simple one")
        Assert.equal ["multiple", "ones"] (getTags "#multiple #ones")
        Assert.equal ["comma"] (getTags "with #comma, right")
        Assert.equal ["dash-now"] (getTags "with #dash-now right")
        Assert.equal ["thrashwithin"] (getTags "any #thrash#within a word")
      test "ignores a single hash" do
        Assert.equal [] (getTags "nothing # here")
  -- these fail because of a maximum call stack size, since when i
  -- imported them from Pangolin
  quickCheck crumbify1
  quickCheck crumbify2
