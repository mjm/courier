module Request.Post exposing (posts)

import Data.Post as Post exposing (Post)
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
