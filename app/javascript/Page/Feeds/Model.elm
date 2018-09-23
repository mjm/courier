module Page.Feeds.Model exposing (Model, Message(..))

import Data.Event exposing (Event)
import Data.Feed exposing (Feed, DraftFeed)
import Http
import Page exposing (Page)


type alias Model =
    { feeds : List Feed
    , draftFeed : Maybe DraftFeed
    , page : Page Message
    }


type Message
    = Noop
    | PageMsg Page.Message
    | EventOccurred Event
    | SetAddingFeed Bool
    | SetDraftFeedUrl String
    | AddFeed
    | FeedAdded (Result Http.Error Feed)
    | RefreshFeed Feed
    | FeedRefreshed (Result Http.Error ())
    | UpdateAutoposting Feed Bool
    | SettingsUpdated (Result Http.Error Feed)
    | DeleteFeed Feed
    | ConfirmDeleteFeed Feed
    | FeedDeleted Feed (Result Http.Error ())
