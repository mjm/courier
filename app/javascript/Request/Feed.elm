module Request.Feed exposing (..)

import Data.Feed as Feed exposing (Feed, DraftFeed)
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


register : DraftFeed -> Http.Request Feed
register feed =
    apiBuilder "RegisterFeed"
        |> withJsonBody (Feed.encode feed)
        |> withExpect (Http.expectJson Feed.decoder)
        |> toRequest
