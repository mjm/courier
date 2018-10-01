module Data.Event exposing (Event(..), decoder)

import Data.Feed as Feed exposing (Feed)
import Data.Tweet as Tweet exposing (Tweet)
import Json.Decode as Decode exposing (Decoder, maybe, oneOf, succeed)
import Json.Decode.Pipeline exposing (required)


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
    succeed TweetUpdated
        |> required "tweet" Tweet.decoder


tweetCreatedDecoder : Decoder Event
tweetCreatedDecoder =
    succeed TweetCreated
        |> required "tweet" Tweet.decoder


feedUpdatedDecoder : Decoder Event
feedUpdatedDecoder =
    succeed FeedUpdated
        |> required "feed" Feed.decoder
