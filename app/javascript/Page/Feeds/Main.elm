port module Page.Feeds.Main exposing (main)

import Browser
import Data.Feed as Feed exposing (Feed)
import Json.Decode exposing (decodeValue)
import Json.Encode as Encode
import Page
import Page.Feeds.Flags exposing (Flags)
import Page.Feeds.Model as Model exposing (Message(..), Model)
import Page.Feeds.Update exposing (update)
import Page.Feeds.View exposing (view)
import Task


port events : (Encode.Value -> msg) -> Sub msg


init : Flags -> ( Model, Cmd Message )
init flags =
    ( { feeds = feedsFromFlags flags
      , draftFeed = Nothing
      , page =
            Page.init
                flags
                PageMsg
      }
    , Task.perform PageMsg Page.initTask
    )


feedsFromFlags : Flags -> List Feed
feedsFromFlags flags =
    decodeValue Feed.listDecoder flags.feeds
        |> Result.withDefault []


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ Page.subscriptions model.page
        , events EventOccurred
        ]


main : Program Flags Model Message
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
