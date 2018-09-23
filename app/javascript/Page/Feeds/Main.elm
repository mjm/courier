module Page.Feeds.Main exposing (main)

import Data.Feed as Feed exposing (Feed)
import Html
import Json.Decode exposing (decodeValue)
import Page
import Page.Feeds.Flags exposing (Flags)
import Page.Feeds.Model as Model exposing (Model, Message(..))
import Page.Feeds.Update exposing (update)
import Page.Feeds.View exposing (view)
import Task
import Unwrap


init : Flags -> ( Model, Cmd Message )
init flags =
    { feeds = feedsFromFlags flags
    , draftFeed = Nothing
    , page =
        Page.init
            flags
            PageMsg
            EventOccurred
    }
        ! [ Task.perform PageMsg Page.initTask ]


feedsFromFlags : Flags -> List Feed
feedsFromFlags flags =
    decodeValue Feed.listDecoder flags.feeds
        |> Unwrap.result


subscriptions : Model -> Sub Message
subscriptions model =
    Page.subscriptions model.page


main : Program Flags Model Message
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
