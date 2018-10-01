module Util.Date exposing (decoder)

import Date exposing (Date)
import Iso8601
import Json.Decode as Decode exposing (Decoder, map, string)


decoder : Decoder (Maybe Date)
decoder =
    map Date.fromIsoString Iso8601.decoder
        |> map Result.toMaybe
