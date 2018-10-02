port module Page.Posts.Main exposing (main)

import Browser
import Data.Tweet as Tweet exposing (Tweet)
import Json.Decode exposing (decodeValue)
import Json.Encode as Encode
import Page
import Page.Posts.Flags exposing (Flags)
import Page.Posts.Model as Model exposing (Message(..), Model)
import Page.Posts.Update exposing (update)
import Page.Posts.View exposing (view)
import Task
import Util.Editable exposing (Editable(..))


port events : (Encode.Value -> msg) -> Sub msg


init : Flags -> ( Model, Cmd Message )
init flags =
    ( { tweets = tweetsFromFlags flags
      , page =
            Page.init
                flags
                PageMsg
      }
    , Task.perform PageMsg Page.initTask
    )


tweetsFromFlags : Flags -> List (Editable Tweet)
tweetsFromFlags flags =
    case decodeValue Tweet.listDecoder flags.tweets of
        Ok ts ->
            List.map Viewing ts

        Err _ ->
            []


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
