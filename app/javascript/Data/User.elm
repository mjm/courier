module Data.User exposing (User, avatarUrl, decoder)

import Date exposing (Date)
import Json.Decode as Decode exposing (Decoder, string, bool)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Util.Date


type alias User =
    { username : String
    , name : String
    , subscribed : Bool
    , subscriptionExpiresAt : Maybe Date
    }


avatarUrl : User -> String
avatarUrl user =
    "https://avatars.io/twitter/" ++ user.username


decoder : Decoder User
decoder =
    decode User
        |> required "username" string
        |> required "name" string
        |> optional "subscribed" bool False
        |> optional "subscriptionExpiresAt" Util.Date.decoder Nothing
