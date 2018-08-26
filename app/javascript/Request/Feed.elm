module Request.Feed exposing (..)

import Data.Feed as Feed exposing (Feed, DraftFeed, SettingsChanges)
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


refresh : Feed -> Http.Request ()
refresh feed =
    let
        body =
            Encode.object [ ( "feed_id", Encode.int feed.id ) ]
    in
        apiBuilder "RefreshFeed"
            |> withJsonBody body
            |> withExpect (Http.expectJson (Decode.succeed ()))
            |> toRequest


updateSettings : Feed -> SettingsChanges -> Http.Request Feed
updateSettings feed settings =
    let
        body =
            Encode.object
                [ ( "feed_id", Encode.int feed.id )
                , ( "settings", Feed.encodeSettings settings )
                ]
    in
        apiBuilder "UpdateFeedSettings"
            |> withJsonBody body
            |> withExpect (Http.expectJson Feed.decoder)
            |> toRequest
