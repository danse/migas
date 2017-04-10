module Main where

import Prelude
import Data.Array (snoc, filter, reverse)
import Data.Array as Array
import Data.Time (Time)
import Data.Int (toNumber, round)
import Data.String (split, take, drop, length, Pattern(..), joinWith)
import Data.String.Utils (stripChars)
import Text.Smolder.HTML as HTML
import Text.Smolder.HTML.Attributes as Attributes
import Text.Smolder.Markup (text, (!), MarkupM)
import Text.Smolder.Renderer.String (render)
import Data.List.Lazy (replicate, foldl)
import Data.Foldable (fold)
import Autocategorise (classifier)

-- import Data.Maybe (fromMaybe)

{-#

The structure of a description that is ready to be rendered is kind of
complex. In the general case of multiple tags, the output can be
composed of multiple sequences of:

- solid coloured strings
- highlighted strings
- strings that are greyed out

with the constraint that solid coloured strings always precede greyed
strings, but i might ignore this constraint to make code simpler.

Then there are the crumbs. Crumbs always stay in the solid coloured
section.

#-}

data DescriptionSection = Plain String | Linked String

sectionLength :: DescriptionSection -> Int
sectionLength (Plain s) = length s
sectionLength (Linked s) = length s

type ProcessedDescription = {
     solid :: Array DescriptionSection,
     grey :: Array DescriptionSection
}

newtype Entry = Entry {
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
  where newEntry = Entry {
          duration: du,
          description: de,
          start: st
          }

getEntries :: State -> Array Entry
getEntries s = s.entries

getDuration :: Entry -> Number
getDuration (Entry r) = r.duration

getDescription :: Entry -> String
getDescription (Entry r) = r.description

type Margin = {
  time :: Time,
  description :: String,
  value :: Number
  }

fromEntryToMargin :: Entry -> Margin
fromEntryToMargin (Entry r) = {
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

words :: String -> Array String
words = split (Pattern " ")

getTags :: String -> Array String
getTags = map cleanTag <<< filter isTag <<< words

linkCategories :: Array String -> String -> Array DescriptionSection
linkCategories categories = map toSection <<< words
  where toSection word
          | Array.elem word categories = Linked word
          | otherwise = Plain word

produceCrumbs :: Int -> DescriptionSection
produceCrumbs i = Plain (foldl (<>) "" (replicate i "."))

-- make sure that the description section is as long as the value
-- associated to it. If it's not, add crumbs
crumbify :: Int -> Array DescriptionSection -> Array DescriptionSection
crumbify minutes sections = f (minutes - sum (map sectionLength sections))
  where f delta
          | delta > 0 = sections <> [produceCrumbs delta]
          | otherwise = sections
        sum = Array.foldl (+) 0

processDescription :: Array String -> String -> Int -> ProcessedDescription
processDescription categories description minutes =
  let plainSolid = take minutes description
      plainGrey = drop minutes description
      solid = linkCategories categories plainSolid
      grey = linkCategories categories plainGrey
  in { solid: crumbify minutes solid, grey: grey }

markupDescriptionSection :: DescriptionSection -> MarkupM _ Unit
markupDescriptionSection (Plain s) = HTML.span (text (s <> " "))
markupDescriptionSection (Linked s) = (HTML.a ! Attributes.href s) (text (s <> " "))

-- I'm looking for a function Monad m, Foldable f => f m -> m
foldHTML :: Array (HTML.Html _) -> (HTML.Html _)
foldHTML = fold

markupDescriptionSections :: Array DescriptionSection -> MarkupM _ Unit
markupDescriptionSections = foldHTML <<< map markupDescriptionSection

renderEntry :: (String -> String) -> Entry -> String
renderEntry classify (Entry entry) = render $ do
  HTML.br
  (HTML.span ! Attributes.className "time") (text (show dur))
  markupDescriptionSections processed.solid
  (HTML.span ! Attributes.className "extra") (markupDescriptionSections processed.grey)
  where dur = round entry.duration
        des = entry.description
        cat = classify des
        processed = processDescription [cat] des dur

renderEntries :: State -> String
renderEntries s = joinWith " " $ reverse $ map (renderEntry classify) s.entries
  where classify = classifier (map (\ (Entry e) -> e.description) s.entries)

renderFolder :: String -> String -> String
renderFolder base "" = renderFolder base "default"
renderFolder base folder = render $ do
  (HTML.a ! Attributes.href (base <> "?" <> folder)) (text folder)
