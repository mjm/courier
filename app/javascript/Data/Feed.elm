module Data.Feed exposing (DraftFeed, Feed, SettingsChanges, decoder, displayName, encode, encodeSettings, listDecoder)

import Iso8601
import Json.Decode as Decode exposing (Decoder, bool, int, list, maybe, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode exposing (Value)
import Time exposing (Posix)


type alias Feed =
    { id : Int
    , url : String
    , title : String
    , refreshedAt : Maybe Posix
    , homePageUrl : String
    , settings : Settings
    }


type alias Settings =
    { autopost : Bool }


type alias DraftFeed =
    { url : String }


type alias SettingsChanges =
    { autopost : Maybe Bool }


displayName : Feed -> String
displayName feed =
    if String.isEmpty feed.title then
        feed.url

    else
        feed.title


defaultSettings : Settings
defaultSettings =
    { autopost = False }


decoder : Decoder Feed
decoder =
    succeed Feed
        |> required "id" int
        |> required "url" string
        |> optional "title" string ""
        |> optional "refreshedAt" (maybe Iso8601.decoder) Nothing
        |> optional "homePageUrl" string ""
        |> optional "settings" settingsDecoder defaultSettings


listDecoder : Decoder (List Feed)
listDecoder =
    Decode.list decoder


settingsDecoder : Decoder Settings
settingsDecoder =
    succeed Settings
        |> optional "autopost" bool False


encode : DraftFeed -> Value
encode feed =
    Encode.object
        [ ( "url", Encode.string feed.url ) ]


encodeSettings : Int -> SettingsChanges -> Value
encodeSettings id changes =
    Encode.object
        [ ( "id", Encode.int id )
        , ( "autopost", encodeSetting changes.autopost )
        ]


encodeSetting : Maybe Bool -> Value
encodeSetting x =
    case x of
        Just isOn ->
            if isOn then
                Encode.string "ON"

            else
                Encode.string "OFF"

        Nothing ->
            Encode.string "UNCHANGED"
