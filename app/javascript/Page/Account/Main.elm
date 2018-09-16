module Page.Account.Main exposing (main)

import Data.User as User exposing (User)
import Html exposing (..)
import Json.Decode exposing (decodeValue)
import Page.Account.Flags exposing (Flags)
import Page.Account.Model exposing (Model, Message(..))
import Page.Account.View exposing (view)
import Unwrap


init : Flags -> ( Model, Cmd Message )
init flags =
    { user = userFromFlags flags
    , stripeKey = flags.stripeKey
    }
        ! []


userFromFlags : Flags -> User
userFromFlags flags =
    decodeValue User.decoder flags.user
        |> Unwrap.result


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    ( model, Cmd.none )


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
