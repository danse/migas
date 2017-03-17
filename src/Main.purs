module Main where

import Prelude
import Data.Array (snoc, filter, reverse)
import Data.Time (Time)
import Data.Int (toNumber, round)
import Data.String (split, take, drop, length, Pattern(..), joinWith)
import Data.String.Utils (stripChars)
import Text.Smolder.HTML as HTML
import Text.Smolder.HTML.Attributes as Attributes
import Text.Smolder.Markup (text, (!))
import Text.Smolder.Renderer.String (render)
import Data.Tuple (Tuple(..), fst, snd)
import Data.List.Lazy (replicate)
import Data.Foldable (foldlDefault)

-- import Data.Maybe (fromMaybe)

type Entry = {
  start :: Time,
  duration :: Number,
  description :: String
  }

{-#

-- a DayEnd is a document element that helps visually understand the data
type DayEnd = {
  day :: Time,
  sum :: Number
}

-- a Mark is a document fragment that gets appended to show recorded values
-- type Mark = Entry | DayEnd

#-}

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
getTags = map cleanTag <<< filter isTag <<< split (Pattern " ")

-- adapt the description length to the amount of minutes passed
crumbify :: String -> Int -> Tuple String String
crumbify description minutes =
  let separatedDots = replicate minutes "."
      dots = foldlDefault (<>) "" separatedDots
      concatenated = description <> dots
  in Tuple (take minutes concatenated) (drop minutes description)

renderEntry :: Entry -> String
renderEntry e = render $ do
  HTML.br
  (HTML.span ! Attributes.className "time") (text (show d))
  HTML.span (text included)
  (HTML.span ! Attributes.className "extra") (text extra)
  where d = round e.duration
        included = fst $ crumbify e.description d
        extra = snd $ crumbify e.description d

renderEntries :: State -> String
renderEntries s = joinWith " " $ reverse $ map renderEntry s.entries
