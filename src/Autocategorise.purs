module Autocategorise where

import Prelude (
  class Monoid,
  class Semigroup,
  Ordering(..),
  compare,
  map,
  not,
  (+),
  (<<<))
import Data.Set as Set
import Data.Map as Map
import Data.Array as Array
import Data.List (fold)
import Data.String as String
import Data.Tuple as Tuple
import Data.Maybe (Maybe(..), fromMaybe, isJust)

newtype Stats = Stats (Map.Map String Int)

instance semigroupStats :: Semigroup Stats where
  append (Stats a) (Stats b) = Stats (Map.unionWith (+) a b)
instance monoidStats :: Monoid Stats where
  mempty = Stats (Map.empty)

getStats :: Array String -> Stats
getStats = fold <<< map (\x -> Stats (Map.singleton x 1))

showStats :: Stats -> Set.Set (Tuple.Tuple String (Maybe Int))
showStats (Stats s) = Set.map (\k -> Tuple.Tuple k (Map.lookup k s)) (Map.keys s)

compareFirstJust :: Tuple.Tuple (Maybe Int) String -> Tuple.Tuple (Maybe Int) String -> Ordering
compareFirstJust (Tuple.Tuple (Just i1) _) (Tuple.Tuple (Just i2) _) = compare i2 i1
compareFirstJust _ _ = EQ

mostFrequentTuples :: Stats -> Array String -> Array (Tuple.Tuple (Maybe Int) String)
mostFrequentTuples (Stats m) = sort <<< filter <<< map enhance
  where sort = Array.sortBy compareFirstJust
        filter = Array.filter (isJust <<< Tuple.fst)
        enhance x = Tuple.Tuple (Map.lookup x m) x

mostFrequent :: Stats -> Array String -> Array String
mostFrequent s = map Tuple.snd <<< mostFrequentTuples s

classify :: Stats -> Array String -> String
classify s = fromMaybe "~ empty ~" <<< Array.head <<< mostFrequent s

stopWords :: Set.Set String
stopWords = Set.fromFoldable [
  "this",
  "and",
  "the",
  "a",
  "to",
  "about",
  "of",
  "from",
  "with",
  "some",
  "my",
  "for",
  "mainly",
  "it",
  "on",
  "in"
  ]

tokenise :: String -> Array String
tokenise = filter <<< split
  where filter = Array.filter (\x -> not (Set.member x stopWords))
        split = String.split (String.Pattern " ")

classifier :: Array String -> String -> String
classifier sentences = classify stats <<< tokenise
  where stats = (getStats <<< Array.concat <<< map tokenise) sentences
