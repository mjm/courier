module Data.User exposing (User, avatarUrl, decoder, empty)

import Iso8601
import Json.Decode as Decode exposing (Decoder, bool, maybe, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Time exposing (Posix)


type alias User =
    { username : String
    , name : String
    , subscribed : Bool
    , subscriptionExpiresAt : Maybe Posix
    , subscriptionRenewsAt : Maybe Posix
    }


empty : User
empty =
    User "" "" False Nothing Nothing


avatarUrl : User -> String
avatarUrl user =
    "https://avatars.io/twitter/" ++ user.username


decoder : Decoder User
decoder =
    succeed User
        |> required "username" string
        |> required "name" string
        |> optional "subscribed" bool False
        |> optional "subscriptionExpiresAt" (maybe Iso8601.decoder) Nothing
        |> optional "subscriptionRenewsAt" (maybe Iso8601.decoder) Nothing
