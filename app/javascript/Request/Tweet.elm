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


update : Tweet -> Http.Request Tweet
update tweet =
    let
        body =
            Encode.object
                [ ( "id", Encode.int tweet.id )
                , ( "body", Encode.string tweet.body )
                ]
    in
        apiBuilder "UpdateTweet"
            |> withJsonBody body
            |> withExpect (Http.expectJson Tweet.decoder)
            |> toRequest
