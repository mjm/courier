module Data.User exposing (User, decoder)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required)


type alias User =
    { username : String
    , name : String
    }


decoder : Decoder User
decoder =
    decode User
        |> required "username" string
        |> required "name" string
