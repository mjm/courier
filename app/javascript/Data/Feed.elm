module Data.Feed exposing (Feed, DraftFeed, SettingsChanges, displayName, decoder, listDecoder, encode, encodeSettings)

import Date exposing (Date)
import Json.Decode as Decode exposing (Decoder, int, string, list, bool)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode as Encode exposing (Value)
import Util.Date


type alias Feed =
    { id : Int
    , url : String
    , title : String
    , refreshedAt : Maybe Date
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
    decode Feed
        |> required "id" int
        |> required "url" string
        |> optional "title" string ""
        |> optional "refreshedAt" Util.Date.decoder Nothing
        |> optional "homePageUrl" string ""
        |> optional "settings" settingsDecoder defaultSettings


listDecoder : Decoder (List Feed)
listDecoder =
    Decode.list decoder


settingsDecoder : Decoder Settings
settingsDecoder =
    decode Settings
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
encodeSetting value =
    case value of
        Just value ->
            if value then
                Encode.string "ON"
            else
                Encode.string "OFF"

        Nothing ->
            Encode.string "UNCHANGED"
