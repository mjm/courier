module Page.Feeds.Model exposing (Model, Modal, Message(..))

import Data.Feed exposing (Feed, DraftFeed)
import Data.User exposing (User)
import Date exposing (Date)
import Http
import Time exposing (Time)


type alias Model =
    { user : User
    , feeds : List Feed
    , draftFeed : Maybe DraftFeed
    , errors : List String
    , modal : Maybe Modal
    , now : Date
    }


type alias Modal =
    { title : String
    , body : String
    , confirmText : String
    , confirmMsg : Message
    }


type Message
    = Noop
    | DismissError String
    | DismissModal
    | Tick Time
    | FeedsLoaded (Result Http.Error (List Feed))
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
