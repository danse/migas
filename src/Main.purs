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
import Data.List.Types (List)
import Data.Foldable (fold, foldlDefault)
import Autocategorise (classifier)
import Data.Map as Map
import Data.Maybe as Maybe
import Data.Semigroup (class Semigroup)
import Data.Monoid (class Monoid)
-- import Data.Int (toNumber)

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
instance eqDescriptionSection :: Eq DescriptionSection where
  eq (Plain s1) (Plain s2) = eq s1 s2
  eq (Linked s1) (Linked s2) = eq s1 s2
  eq _ _ = false
instance showDescriptionSection :: Show DescriptionSection where
  show (Plain s) = "Plain " <> show s
  show (Linked s) = "Linked " <> show s

descriptionSectionLength :: DescriptionSection -> Int
descriptionSectionLength (Plain s) = length s
descriptionSectionLength (Linked s) = length s

descriptionSectionArrayLength :: Array DescriptionSection -> Int
descriptionSectionArrayLength = foldlDefault f 0
  where f b a = b + descriptionSectionLength a

sectionLength :: DescriptionSection -> Int
sectionLength (Plain s) = length s
sectionLength (Linked s) = length s

newtype Shaped a = Shaped { solid :: a, grey :: a }
type ProcessedDescription = Shaped (Array DescriptionSection)

instance eqShaped :: Eq a => Eq (Shaped a) where
  eq (Shaped p1) (Shaped p2) = eq p1.solid p2.solid && eq p1.grey p2.grey
instance showShaped :: Show a => Show (Shaped a) where
  show (Shaped a) = "Shaped solid: " <> show a.solid <> " grey: " <> show a.grey

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
          | delta > 1 = sections <> [produceCrumbs (delta)]
          | otherwise = sections
        sum = Array.foldl (+) 0

shorten :: forall a. Array a -> Array a
shorten a = case Array.unsnoc a of
  Maybe.Nothing -> []
  Maybe.Just { init: xs, last: x } -> xs

-- take the minimum amount of description sections such that the sum
-- of their lengths is greater or equal the number of minutes
takeSections :: Int -> Array DescriptionSection -> Array DescriptionSection
takeSections _ [] = []
takeSections m a
  | descriptionSectionArrayLength (shorten a) >= m = takeSections m (shorten a)
  | otherwise = a

dropSections :: Int -> Array DescriptionSection -> Array DescriptionSection
dropSections m a = Array.drop (Array.length taken) a
  where taken = takeSections m a

processDescription :: Array String -> String -> Int -> ProcessedDescription
processDescription categories description minutes =
  let sections = linkCategories categories description
      solid = takeSections minutes sections
      grey = dropSections minutes sections
  in Shaped { solid: crumbify minutes solid, grey: grey }

markupDescriptionSection :: DescriptionSection -> MarkupM _ Unit
markupDescriptionSection (Plain s) = HTML.span (text (s))
markupDescriptionSection (Linked s) = (HTML.a ! Attributes.href s) (text (s))

-- I'm looking for a function Monad m, Foldable f => f m -> m
foldHTML :: Array (HTML.Html _) -> (HTML.Html _)
foldHTML = fold

markupDescriptionSections :: Array DescriptionSection -> MarkupM _ Unit
markupDescriptionSections = foldHTML <<< map render
  where render s = do
          markupDescriptionSection s
          HTML.span (text " ")

renderEntry :: (String -> String) -> Entry -> String
renderEntry classify (Entry entry) = render $ do
  HTML.br
  (HTML.span ! Attributes.className "time") (text (show dur))
  markupDescriptionSections processed.solid
  (HTML.span ! Attributes.className "extra") (markupDescriptionSections processed.grey)
  where dur = round entry.duration
        des = entry.description
        cat = classify des
        processed = (\ (Shaped r) -> r) (processDescription [cat] des dur)

renderEntries :: State -> String
renderEntries s = joinWith " " $ reverse $ map (renderEntry classify) s.entries
  where classify = classifier (map (\ (Entry e) -> e.description) s.entries)

renderFolder :: String -> String -> String
renderFolder base "" = renderFolder base "default"
renderFolder base folder = render $ do
  (HTML.a ! Attributes.href (base <> "?" <> folder)) (text folder)

type ChartData = { label :: String, value :: Number }

newtype ChartStats = ChartStats (Map.Map String Number)

instance semigroupChartStats :: Semigroup ChartStats where
  append (ChartStats a) (ChartStats b) = ChartStats (Map.unionWith (+) a b)
instance monoidChartStats :: Monoid ChartStats where
  mempty = ChartStats (Map.empty)

lookupCharStats k (ChartStats c) = Map.lookup k c
keysCharStats (ChartStats c) = Map.keys c

getChartData :: State -> Array ChartData
getChartData s =
  let entryDescription (Entry e) = e.description
      entryDuration (Entry e) = e.duration
      classify = classifier (map entryDescription s.entries)
      makeSingleton (Entry e) = ChartStats (Map.singleton (classify e.description) e.duration)
      allStats = map makeSingleton s.entries
      unifiedStats = fold allStats
      toValue k = Maybe.fromMaybe 0.0 (lookupCharStats k unifiedStats)
      toData k = { label: k, value: toValue k }
  in Array.fromFoldable (map toData (keysCharStats unifiedStats))
