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


cancel : Tweet -> Http.Request Tweet
cancel tweet =
    let
        body =
            Encode.object [ ( "id", Encode.int tweet.id ) ]

        decoder =
            Decode.field "tweet" Tweet.decoder
    in
        tweetsBuilder "CancelTweet"
            |> withJsonBody body
            |> withExpect (Http.expectJson decoder)
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
            |> withExpect (Http.expectJson Tweet.decoder)
            |> toRequest


post : Tweet -> Http.Request Tweet
post tweet =
    let
        body =
            Encode.object [ ( "id", Encode.int tweet.id ) ]
    in
        tweetsBuilder "SubmitTweet"
            |> withJsonBody body
            |> withExpect (Http.expectJson Tweet.decoder)
            |> toRequest
