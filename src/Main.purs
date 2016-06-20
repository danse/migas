module Main where

import Prelude (Unit)
import Data.Array (snoc)

type State = {
  records :: Array Record
  -- tagReports :: Map String Int
  }

type Record = {
  -- start :: Time,
  duration :: Number,
  description :: String
  }

initialState = { records: [] }

addEntry :: Number -> String -> State -> State
addEntry dur desc state = state { records = snoc state.records { duration: dur, description: desc } }

getRecords :: State -> Array Record
getRecords s = s.records

getDuration :: Record -> Number
getDuration r = r.duration

getDescription :: Record -> String
getDescription r = r.description
