module Request.Tweet exposing (..)

import Data.Tweet as Tweet exposing (Tweet)
import Http
import HttpBuilder exposing (withExpect, withJsonBody, toRequest)
import Json.Decode as Decode
import Json.Encode as Encode
import Request.Helpers exposing (apiBuilder)


tweetsBuilder : String -> HttpBuilder.RequestBuilder ()
tweetsBuilder =
    apiBuilder "Tweets"


tweetDecoder : Decode.Decoder Tweet
tweetDecoder =
    Decode.field "tweet" Tweet.decoder


cancel : Tweet -> Http.Request Tweet
cancel tweet =
    let
        body =
            Encode.object [ ( "id", Encode.int tweet.id ) ]
    in
        tweetsBuilder "CancelTweet"
            |> withJsonBody body
            |> withExpect (Http.expectJson tweetDecoder)
            |> toRequest


uncancel : Tweet -> Http.Request Tweet
uncancel tweet =
    let
        body =
            Encode.object [ ( "id", Encode.int tweet.id ) ]
    in
        tweetsBuilder "UncancelTweet"
            |> withJsonBody body
            |> withExpect (Http.expectJson tweetDecoder)
            |> toRequest


update : Tweet -> Bool -> Http.Request Tweet
update tweet shouldPost =
    let
        body =
            Encode.object
                [ ( "id", Encode.int tweet.id )
                , ( "body", Encode.string tweet.body )
                , ( "shouldPost", Encode.bool shouldPost )
                ]
    in
        tweetsBuilder "UpdateTweet"
            |> withJsonBody body
            |> withExpect (Http.expectJson tweetDecoder)
            |> toRequest


post : Tweet -> Http.Request Tweet
post tweet =
    let
        body =
            Encode.object [ ( "id", Encode.int tweet.id ) ]
    in
        tweetsBuilder "PostTweet"
            |> withJsonBody body
            |> withExpect (Http.expectJson tweetDecoder)
            |> toRequest
