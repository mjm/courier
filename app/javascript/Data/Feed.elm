module Data.Feed exposing (Feed, DraftFeed, displayName, decoder, listDecoder, encode)

import Json.Decode as Decode exposing (Decoder, int, string, list)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Json.Encode as Encode exposing (Value)


type alias Feed =
    { id : Int
    , url : String
    , title : String
    , homePageUrl : String
    }


type alias DraftFeed =
    { url : String }


displayName : Feed -> String
displayName feed =
    if String.isEmpty feed.title then
        feed.url
    else
        feed.title


decoder : Decoder Feed
decoder =
    decode Feed
        |> required "id" int
        |> required "url" string
        |> optional "title" string ""
        |> optional "homePageUrl" string ""


listDecoder : Decoder (List Feed)
listDecoder =
    Decode.list decoder


encode : DraftFeed -> Value
encode feed =
    Encode.object
        [ ( "url", Encode.string feed.url ) ]
