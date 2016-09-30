module Main where

import Prelude
import Data.Array (snoc, filter)
import Data.Time (Time)
import Data.Int (toNumber)
import Data.String (split, take, length)
import Data.String.Utils (stripChars)
-- import Data.Maybe (fromMaybe)

type Entry = {
  start :: Time,
  duration :: Number,
  description :: String
  }

type State = {
  entries :: Array Entry
  -- tagReports :: Map String Int
  }

initialState :: { entries :: Array Entry }
initialState = { entries: [] }

addEntry :: Number -> String -> Time -> State -> State
addEntry du de st state = state { entries = snoc state.entries newEntry }
  where newEntry = {
          duration: du,
          description: de,
          start: st
          }

getEntries :: State -> Array Entry
getEntries s = s.entries

getDuration :: Entry -> Number
getDuration r = r.duration

getDescription :: Entry -> String
getDescription r = r.description

type Margin = {
  time :: Time,
  description :: String,
  value :: Number
  }

fromEntryToMargin :: Entry -> Margin
fromEntryToMargin r = {
  description: r.description,
  time: r.start,
  value: hours
  }
  where hours = r.duration / (toNumber 60)

exportAsMarginFile :: State -> Array Margin
exportAsMarginFile state = map fromEntryToMargin state.entries

isTag :: String -> Boolean
isTag t = take 1 t == "#" && length t > 1

cleanTag :: String -> String
cleanTag = stripChars "#,;."

getTags :: String -> Array String
getTags = map cleanTag <<< filter isTag <<< split " " 
