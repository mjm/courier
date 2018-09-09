module Page.Feeds.Main exposing (main)

import Data.Feed as Feed exposing (Feed)
import Data.User as User exposing (User)
import Date
import Html
import Json.Decode exposing (decodeValue)
import Page.Feeds.Flags exposing (Flags)
import Page.Feeds.Model as Model exposing (Model)
import Page.Feeds.Update exposing (Message(..), update)
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
    , now = Date.fromTime 0
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
    Time.every (10 * Time.second) Tick


main : Program Flags Model Message
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
