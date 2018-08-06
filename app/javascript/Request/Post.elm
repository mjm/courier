module Request.Post exposing (..)

import Data.Post as Post exposing (Post)
import Data.Tweet as Tweet exposing (Tweet)
import Http
import HttpBuilder exposing (withExpect, withJsonBody, toRequest)
import Json.Decode as Decode
import Json.Encode as Encode
import Request.Helpers exposing (apiBuilder)


posts : Http.Request (List Post)
posts =
    let
        decoder =
            Decode.field "posts" Post.listDecoder
    in
        apiBuilder "GetPosts"
            |> withJsonBody (Encode.object [])
            |> withExpect (Http.expectJson decoder)
            |> toRequest


cancelTweet : Tweet -> Http.Request Tweet
cancelTweet tweet =
    let
        body =
            Encode.object [ ( "id", Encode.int tweet.id ) ]
    in
        apiBuilder "CancelTweet"
            |> withJsonBody body
            |> withExpect (Http.expectJson Tweet.decoder)
            |> toRequest
