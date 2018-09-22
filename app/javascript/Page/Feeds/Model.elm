module Page.Feeds.Model exposing (Model, Message(..))

import ActionCable exposing (ActionCable)
import ActionCable.Identifier as ID
import ActionCable.Msg as ACMsg
import Data.Feed exposing (Feed, DraftFeed)
import Data.User exposing (User)
import Date exposing (Date)
import Http
import Json.Decode as Decode
import Time exposing (Time)
import Views.Modal exposing (Modal)


type alias Model =
    { user : User
    , feeds : List Feed
    , draftFeed : Maybe DraftFeed
    , errors : List String
    , modal : Maybe (Modal Message)
    , now : Date
    , cable : ActionCable Message
    }


type Message
    = Noop
    | CableMsg ACMsg.Msg
    | Subscribe ()
    | HandleSocketData ID.Identifier Decode.Value
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
