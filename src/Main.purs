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

{-#

The structure of a description that is ready to be rendered is kind of
complex. In the general case of multiple tags, the output can be
composed of multiple sequences of:

- solid coloured strings
- highlighted strings
- strings that are greyed out

with the constraint that solid coloured strings always precede grayed
strings, but i might ignore this constraint to make code simpler.

Then there are the crumbs. Crumbs always stay in the solid coloured
section.

#-}

type DescriptionSection = Plain String | Linked String

sectionLength (Plain s) = length s
sectionLength (Linked s) = length s

type ProcessedDescription = {
     solid: [DescriptionSection],
     grey: [DescriptionSection]
}

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

words = split (Pattern " ")

getTags :: String -> Array String
getTags = map cleanTag <<< filter isTag <<< words

linkCategories :: [String] -> String -> [DescriptionSection]
linkCategories categories = map toSection . words
  where toSection word
          | includes categories word = Linked word
          | otherwise = Plain word

-- make sure that the description section is as long as the value
-- associated to it. If it's not, add crumbs
crumbify :: Int -> [DescriptionSection] -> [DescriptionSection]
crumbify minutes sections
  | delta > 0 = sections <> [replicate delta "."]
  | otherwise = sections
  where delta = minutes - sum (map sectionLength sections)

processDescription :: [String] -> String -> Int -> ProcessedDescription
processDescription categories description minutes =
  let plainSolid = take minutes description
      plainGrey = drop minutes description
      solid = linkCategories categories plainSolid
      grey = linkCategories categories plainGrey
  in ProcessedDescription (crumbify solid) grey

renderDescriptionSection :: DescriptionSection -> _
renderDescriptionSection (Plain s) = HTML.span (text s)
renderDescriptionSection (Linked s) = (HTML.a ! Attributes.href s) (text s)

renderEntry :: [String] -> Entry -> String
renderEntry cat e = render $ do
  HTML.br
  (HTML.span ! Attributes.className "time") (text (show d))
  HTML.span (text included)
  (HTML.span ! Attributes.className "extra") (text extra)
  where d = round e.duration
        included = fst $ processDescription cat e.description d
        extra = snd $ processDescription cat e.description d

renderEntries :: State -> String
renderEntries s = joinWith " " $ reverse $ map (renderEntry cat) s.entries
  where cat = autoCategories s.entries

renderFolder :: String -> String -> String
renderFolder base "" = renderFolder base "default"
renderFolder base folder = render $ do
  (HTML.a ! Attributes.href (base <> "?" <> folder)) (text folder)
