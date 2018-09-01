module Util.Date exposing (decoder)

import Date exposing (Date)
import Date.Extra as Date
import Json.Decode as Decode exposing (Decoder, string)


decoder : Decoder (Maybe Date)
decoder =
    Decode.map Date.fromIsoString string
        |> Decode.map Result.toMaybe
