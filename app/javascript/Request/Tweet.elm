module Request.Tweet exposing (..)

import Data.Tweet as Tweet exposing (Tweet)
import Http
import HttpBuilder exposing (withExpect, withJsonBody, toRequest)
import Json.Encode as Encode
import Request.Helpers exposing (apiBuilder)


cancel : Tweet -> Http.Request Tweet
cancel tweet =
    let
        body =
            Encode.object [ ( "id", Encode.int tweet.id ) ]
    in
        apiBuilder "CancelTweet"
            |> withJsonBody body
            |> withExpect (Http.expectJson Tweet.decoder)
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
        apiBuilder "UpdateTweet"
            |> withJsonBody body
            |> withExpect (Http.expectJson Tweet.decoder)
            |> toRequest


post : Tweet -> Http.Request Tweet
post tweet =
    let
        body =
            Encode.object [ ( "id", Encode.int tweet.id ) ]
    in
        apiBuilder "SubmitTweet"
            |> withJsonBody body
            |> withExpect (Http.expectJson Tweet.decoder)
            |> toRequest
