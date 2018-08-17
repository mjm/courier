module Data.Post exposing (Post, decoder, listDecoder)

import Data.Tweet as Tweet exposing (Tweet)
import Date exposing (Date)
import Date.Extra as Date
import Json.Decode as Decode exposing (Decoder, string, list)
import Json.Decode.Pipeline exposing (decode, required, optional)


type alias Post =
    { title : String
    , url : String
    , contentText : String
    , contentHtml : String
    , publishedAt : Maybe Date
    , modifiedAt : Maybe Date
    , tweets : List Tweet
    }


decoder : Decoder Post
decoder =
    decode Post
        |> optional "title" string ""
        |> optional "url" string ""
        |> optional "contentText" string ""
        |> optional "contentHtml" string ""
        |> optional "publishedAt" dateDecoder Nothing
        |> optional "modifiedAt" dateDecoder Nothing
        |> optional "tweets" (list Tweet.decoder) []


dateDecoder : Decoder (Maybe Date)
dateDecoder =
    Decode.map Date.fromIsoString string
        |> Decode.map Result.toMaybe


listDecoder : Decoder (List Post)
listDecoder =
    Decode.list decoder
