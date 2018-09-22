module Page.Feeds.Main exposing (main)

import ActionCable
import Data.Feed as Feed exposing (Feed)
import Data.User as User exposing (User)
import Date
import Html
import Json.Decode exposing (decodeValue)
import Page.Feeds.Flags exposing (Flags)
import Page.Feeds.Model as Model exposing (Model, Message(..))
import Page.Feeds.Update exposing (update)
import Page.Feeds.View exposing (view)
import Task
import Time
import Unwrap


init : Flags -> ( Model, Cmd Message )
init flags =
    { user = userFromFlags flags
    , feeds = feedsFromFlags flags
    , draftFeed = Nothing
    , errors = []
    , modal = Nothing
    , now = Date.fromTime 0
    , cable =
        ActionCable.initCable flags.cableUrl
            |> ActionCable.onWelcome (Just Subscribe)
            |> ActionCable.onDidReceiveData (Just HandleSocketData)
    }
        ! [ Task.perform Tick Time.now ]


feedsFromFlags : Flags -> List Feed
feedsFromFlags flags =
    decodeValue Feed.listDecoder flags.feeds
        |> Unwrap.result


userFromFlags : Flags -> User
userFromFlags flags =
    decodeValue User.decoder flags.user
        |> Unwrap.result


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ Time.every (10 * Time.second) Tick
        , ActionCable.listen CableMsg model.cable
        ]


main : Program Flags Model Message
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
