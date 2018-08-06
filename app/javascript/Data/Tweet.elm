module Data.Tweet exposing (Tweet, Status(..), decoder)

import Json.Decode as Decode exposing (Decoder, string, int)
import Json.Decode.Pipeline exposing (decode, required, optional)


type Status
    = Draft
    | Canceled
    | Posted


type alias Tweet =
    { id : Int
    , body : String
    , status : Status
    }


decoder : Decoder Tweet
decoder =
    decode Tweet
        |> required "id" int
        |> required "body" string
        |> optional "status" (Decode.map statusFromString string) Draft


statusFromString : String -> Status
statusFromString str =
    case str of
        "CANCELED" ->
            Canceled

        "POSTED" ->
            Posted

        _ ->
            Draft
