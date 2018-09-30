module Page.Posts.Main exposing (main)

import Data.Tweet as Tweet exposing (Tweet)
import Html
import Json.Decode exposing (decodeValue)
import Page
import Page.Posts.Flags exposing (Flags)
import Page.Posts.Model as Model exposing (Message(..), Model)
import Page.Posts.Update exposing (update)
import Page.Posts.View exposing (view)
import Task
import Unwrap
import Util.Editable exposing (Editable(..))


init : Flags -> ( Model, Cmd Message )
init flags =
    ( { tweets = tweetsFromFlags flags
      , page =
            Page.init
                flags
                PageMsg
                EventOccurred
      }
    , Task.perform PageMsg Page.initTask
    )


tweetsFromFlags : Flags -> List (Editable Tweet)
tweetsFromFlags flags =
    decodeValue Tweet.listDecoder flags.tweets
        |> Unwrap.result
        |> List.map Viewing


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
