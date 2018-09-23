module Page.Account.Main exposing (main)

import Html exposing (..)
import Page
import Page.Account.Flags exposing (Flags)
import Page.Account.Model exposing (Model, Message(..))
import Page.Account.Update exposing (update)
import Page.Account.View exposing (view)
import Task


init : Flags -> ( Model, Cmd Message )
init flags =
    { stripeKey = flags.stripeKey
    , page =
        Page.init
            flags
            PageMsg
            EventOccurred
    }
        ! [ Task.perform PageMsg Page.initTask ]


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
