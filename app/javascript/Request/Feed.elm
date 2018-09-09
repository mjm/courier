module Request.Feed exposing (..)

import Data.Feed as Feed exposing (Feed, DraftFeed, SettingsChanges)
import Http
import HttpBuilder exposing (withExpect, withJsonBody, toRequest)
import Json.Decode as Decode
import Json.Encode as Encode
import Request.Helpers exposing (apiBuilder)


feedsBuilder : String -> HttpBuilder.RequestBuilder ()
feedsBuilder =
    apiBuilder "Feeds"


feeds : Http.Request (List Feed)
feeds =
    let
        decoder =
            Decode.field "feeds" Feed.listDecoder
    in
        feedsBuilder "GetFeeds"
            |> withJsonBody (Encode.object [])
            |> withExpect (Http.expectJson decoder)
            |> toRequest


register : DraftFeed -> Http.Request Feed
register feed =
    let
        decoder =
            Decode.field "feed" Feed.decoder
    in
        feedsBuilder "RegisterFeed"
            |> withJsonBody (Feed.encode feed)
            |> withExpect (Http.expectJson decoder)
            |> toRequest


refresh : Feed -> Http.Request ()
refresh feed =
    let
        body =
            Encode.object [ ( "feed_id", Encode.int feed.id ) ]
    in
        feedsBuilder "RefreshFeed"
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
        feedsBuilder "UpdateFeedSettings"
            |> withJsonBody body
            |> withExpect (Http.expectJson Feed.decoder)
            |> toRequest
