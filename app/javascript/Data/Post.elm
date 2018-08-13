module Data.Post exposing (Post, decoder, listDecoder)

import Data.Tweet as Tweet exposing (Tweet)
import Json.Decode as Decode exposing (Decoder, string, list)
import Json.Decode.Pipeline exposing (decode, required, optional)


type alias Post =
    { title : String
    , url : String
    , contentText : String
    , contentHtml : String
    , tweets : List Tweet
    }


decoder : Decoder Post
decoder =
    decode Post
        |> optional "title" string ""
        |> optional "url" string ""
        |> optional "contentText" string ""
        |> optional "contentHtml" string ""
        |> optional "tweets" (list Tweet.decoder) []


listDecoder : Decoder (List Post)
listDecoder =
    Decode.list decoder
