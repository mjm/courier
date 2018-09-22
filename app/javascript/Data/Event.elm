module Data.Event exposing (Event(..), decoder)

import Data.Feed as Feed exposing (Feed)
import Data.Tweet as Tweet exposing (Tweet)
import Json.Decode as Decode exposing (Decoder, maybe, oneOf)
import Json.Decode.Pipeline exposing (decode, required)


type Event
    = TweetUpdated Tweet
    | TweetCreated Tweet
    | FeedUpdated Feed


decoder : Decoder Event
decoder =
    oneOf
        [ Decode.field "tweetUpdatedEvent" tweetUpdatedDecoder
        , Decode.field "tweetCreatedEvent" tweetCreatedDecoder
        , Decode.field "feedUpdatedEvent" feedUpdatedDecoder
        ]


tweetUpdatedDecoder : Decoder Event
tweetUpdatedDecoder =
    decode TweetUpdated
        |> required "tweet" Tweet.decoder


tweetCreatedDecoder : Decoder Event
tweetCreatedDecoder =
    decode TweetCreated
        |> required "tweet" Tweet.decoder


feedUpdatedDecoder : Decoder Event
feedUpdatedDecoder =
    decode FeedUpdated
        |> required "feed" Feed.decoder
