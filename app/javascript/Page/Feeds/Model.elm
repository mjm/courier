module Page.Feeds.Model exposing (Model, initial)

import Data.Feed exposing (Feed, DraftFeed)
import Data.User exposing (User)
import Util.Loadable exposing (Loadable(..))


type alias Model =
    { user : Maybe User
    , feeds : Loadable (List Feed)
    , draftFeed : Maybe DraftFeed
    , errors : List String
    }


initial : Model
initial =
    { user = Nothing
    , feeds = Loading
    , draftFeed = Nothing
    , errors = []
    }
