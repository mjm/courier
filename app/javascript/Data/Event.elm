module Data.Event exposing (Event(..), decoder)

import Data.Tweet as Tweet exposing (Tweet)
import Json.Decode as Decode exposing (Decoder, maybe, oneOf)
import Json.Decode.Pipeline exposing (decode, required)


type Event
    = TweetUpdated Tweet


decoder : Decoder Event
decoder =
    oneOf
        [ Decode.field "tweetUpdatedEvent" tweetUpdatedDecoder
        ]


tweetUpdatedDecoder : Decoder Event
tweetUpdatedDecoder =
    decode TweetUpdated
        |> required "tweet" Tweet.decoder
