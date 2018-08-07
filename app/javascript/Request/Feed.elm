module Request.Feed exposing (..)

import Data.Feed as Feed exposing (Feed)
import Http
import HttpBuilder exposing (withExpect, withJsonBody, toRequest)
import Json.Decode as Decode
import Json.Encode as Encode
import Request.Helpers exposing (apiBuilder)


feeds : Http.Request (List Feed)
feeds =
    let
        decoder =
            Decode.field "feeds" Feed.listDecoder
    in
        apiBuilder "GetFeeds"
            |> withJsonBody (Encode.object [])
            |> withExpect (Http.expectJson decoder)
            |> toRequest
