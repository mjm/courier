module Data.User exposing (User, avatarUrl, decoder)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required)


type alias User =
    { username : String
    , name : String
    }


avatarUrl : User -> String
avatarUrl user =
    "https://avatars.io/twitter/" ++ user.username


decoder : Decoder User
decoder =
    decode User
        |> required "username" string
        |> required "name" string
