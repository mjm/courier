module Data.Tweet exposing (Tweet, Status(..), decoder)

import Date exposing (Date)
import Json.Decode as Decode exposing (Decoder, string, int)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Util.Date


type Status
    = Draft
    | Canceled
    | Posted


type alias Tweet =
    { id : Int
    , postId : Int
    , body : String
    , status : Status
    , postedAt : Maybe Date
    , tweetId : Maybe String
    }


decoder : Decoder Tweet
decoder =
    decode Tweet
        |> required "id" int
        |> required "postId" int
        |> required "body" string
        |> optional "status" (Decode.map statusFromString string) Draft
        |> optional "postedAt" Util.Date.decoder Nothing
        |> optional "postedTweetId" (Decode.maybe string) Nothing


statusFromString : String -> Status
statusFromString str =
    case str of
        "CANCELED" ->
            Canceled

        "POSTED" ->
            Posted

        _ ->
            Draft
