port module Page.Account.Main exposing (main)

import Browser
import Html exposing (..)
import Json.Encode as Encode
import Page
import Page.Account.Flags exposing (Flags)
import Page.Account.Model exposing (Message(..), Model)
import Page.Account.Update exposing (update)
import Page.Account.View exposing (view)
import Task


port events : (Encode.Value -> msg) -> Sub msg


init : Flags -> ( Model, Cmd Message )
init flags =
    ( { stripeKey = flags.stripeKey
      , page =
            Page.init
                flags
                PageMsg
      }
    , Task.perform PageMsg Page.initTask
    )


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ Page.subscriptions model.page
        , events EventOccurred
        ]


main : Program Flags Model Message
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
