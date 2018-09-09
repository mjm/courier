module Page.Feeds.Model exposing (Model)

import Data.Feed exposing (Feed, DraftFeed)
import Data.User exposing (User)
import Date exposing (Date)


type alias Model =
    { user : User
    , feeds : List Feed
    , draftFeed : Maybe DraftFeed
    , errors : List String
    , now : Date
    }
