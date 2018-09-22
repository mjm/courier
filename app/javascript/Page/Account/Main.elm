module Page.Account.Main exposing (main)

import Data.User as User exposing (User)
import Date
import Html exposing (..)
import Json.Decode exposing (decodeValue)
import Page.Account.Flags exposing (Flags)
import Page.Account.Model exposing (Model, Message(..))
import Page.Account.Update exposing (update)
import Page.Account.View exposing (view)
import Task
import Time
import Unwrap


init : Flags -> ( Model, Cmd Message )
init flags =
    { user = userFromFlags flags
    , stripeKey = flags.stripeKey
    , now = Date.fromTime 0
    , modal = Nothing
    }
        ! [ Task.perform Tick Time.now ]


userFromFlags : Flags -> User
userFromFlags flags =
    decodeValue User.decoder flags.user
        |> Unwrap.result


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.none


main : Program Flags Model Message
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
