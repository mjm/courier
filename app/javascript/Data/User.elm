module Data.User exposing (User, avatarUrl, decoder)

import Date exposing (Date)
import Json.Decode as Decode exposing (Decoder, bool, string)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Util.Date


type alias User =
    { username : String
    , name : String
    , subscribed : Bool
    , subscriptionExpiresAt : Maybe Date
    , subscriptionRenewsAt : Maybe Date
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
        |> optional "subscriptionRenewsAt" Util.Date.decoder Nothing
