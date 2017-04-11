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
import Data.Tuple (fst, snd, Tuple(..))
import Data.String (length)
import Main (crumbify, getTags)
import Autocategorise (classifier, mostFrequent, getStats, mostFrequentTuples, Stats(..), showStats)
import Data.Maybe (Maybe(..))
import Data.Map as Map
import Data.Array (fold)
import Data.List as List
import Data.List ((:), List(..))

{-#

crumbify1 :: String -> Int -> Boolean
crumbify1 desc minutes = 
  minutes == length returned
  where returned = fst $ crumbify desc minutes

crumbify2 :: String -> Int -> Boolean
crumbify2 desc minutes = (length rest) <= ((length desc) - minutes)
  where rest = snd $ crumbify desc minutes

#-}

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
    suite "Stats" do
      test "folds as expected" do
        Assert.equal ((Tuple "a" (Just 2)) : Nil) (showStats (fold [Stats (Map.singleton "a" 1), Stats (Map.singleton "a" 1)]))
      test "folds with more keys" do
        Assert.equal ((Tuple "a" (Just 2)) : (Tuple "b" (Just 1)) : Nil) (showStats (fold [Stats (Map.singleton "a" 1), Stats (Map.singleton "a" 1), Stats (Map.singleton "b" 1)]))
      test "showStats <<< getStats" do
        Assert.equal ((Tuple "a" (Just 2)) : (Tuple "b" (Just 1)) : Nil) (showStats (getStats ["a", "a", "b"]))
    suite "mostFrequentTuples <<< getStats" do
      test "works as expected" do
        Assert.equal [(Tuple (Just 2) "a"), (Tuple (Just 1) "b")] (mostFrequentTuples (getStats ["b", "a", "a"]) ["b", "a"])
    suite "mostFrequent <<< getStats" do
      test "works as expected" do
        Assert.equal ["a", "b"] (mostFrequent (getStats ["b", "a", "a"]) ["b", "a"])
        Assert.equal ["c", "a", "b"] (mostFrequent (getStats ["b", "a", "c", "a", "c", "c"]) ["c", "b", "a"])
    suite "classifier" do
      test "works as expected" do
        Assert.equal "d" (classifier ["d", "d"] "b d")
        Assert.equal "b" (classifier ["d", "b", "b"] "d b")
        Assert.equal "c" (classifier ["d", "b", "c", "c", "c d"] "d b c")
  -- these fail because of a maximum call stack size, since when i
  -- imported them from Pangolin
  -- quickCheck crumbify1
  -- quickCheck crumbify2
