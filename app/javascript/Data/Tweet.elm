module Data.Tweet exposing (Tweet, decoder)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required)


type alias Tweet =
    { body : String }


decoder : Decoder Tweet
decoder =
    decode Tweet
        |> required "body" string
