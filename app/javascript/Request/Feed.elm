module Request.Feed exposing (delete, feedDecoder, feeds, feedsBuilder, refresh, register, updateSettings)

import Data.Feed as Feed exposing (DraftFeed, Feed, SettingsChanges)
import Http
import HttpBuilder exposing (toRequest, withExpect, withJsonBody)
import Json.Decode as Decode
import Json.Encode as Encode
import Request.Helpers exposing (apiBuilder)


feedsBuilder : String -> HttpBuilder.RequestBuilder ()
feedsBuilder =
    apiBuilder "Feeds"


feedDecoder : Decode.Decoder Feed
feedDecoder =
    Decode.field "feed" Feed.decoder


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
    feedsBuilder "RegisterFeed"
        |> withJsonBody (Feed.encode feed)
        |> withExpect (Http.expectJson feedDecoder)
        |> toRequest


refresh : Feed -> Http.Request ()
refresh feed =
    let
        body =
            Encode.object [ ( "id", Encode.int feed.id ) ]
    in
    feedsBuilder "RefreshFeed"
        |> withJsonBody body
        |> withExpect (Http.expectJson (Decode.succeed ()))
        |> toRequest


updateSettings : Feed -> SettingsChanges -> Http.Request Feed
updateSettings feed settings =
    let
        body =
            Feed.encodeSettings feed.id settings
    in
    feedsBuilder "UpdateFeedSettings"
        |> withJsonBody body
        |> withExpect (Http.expectJson feedDecoder)
        |> toRequest


delete : Feed -> Http.Request ()
delete feed =
    let
        body =
            Encode.object [ ( "id", Encode.int feed.id ) ]
    in
    feedsBuilder "DeleteFeed"
        |> withJsonBody body
        |> withExpect (Http.expectJson (Decode.succeed ()))
        |> toRequest
