module Autocategorise where

import Prelude
import Data.Set as Set
import Data.Map as Map
import Data.Array as Array
import Data.String as String
import Data.Tuple as Tuple
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Foldable (fold)
import Data.Semigroup (class Semigroup)
import Data.Monoid (class Monoid)

newtype Stats = Stats (Map.Map String Int)

instance semigroupStats :: Semigroup Stats where
  append (Stats a) (Stats b) = Stats (Map.unionWith (+) a b)
instance monoidStats :: Monoid Stats where
  mempty = Stats (Map.empty)

getStats :: Array String -> Stats
getStats = Stats <<< fold <<< map (\x -> Map.singleton x 1)

mostFrequent :: Map.Map String Int -> Array String -> Maybe String
mostFrequent m = Array.head <<< map Tuple.snd <<< sort <<< map enhance
  where sort = Array.sortBy (\ a b -> compare (Tuple.fst a) (Tuple.fst b))
        enhance x = Tuple.Tuple (fromMaybe 0 (Map.lookup x m)) x

classify :: Stats -> Array String -> String
classify (Stats m) s = fromMaybe "~ empty ~" (mostFrequent m s)

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
classifier sentences = (classify (getStats sentences) <<< tokenise)
  where stats = (getStats <<< (Array.concat <<< map tokenise)) sentences
