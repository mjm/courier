module Data.Post exposing (Post, decoder, encode)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode exposing (Value)


type alias Post =
    { contentHtml : String }


decoder : Decoder Post
decoder =
    decode Post
        |> required "contentHtml" string


encode : Post -> Value
encode post =
    Encode.object
        [ ( "contentHtml", Encode.string post.contentHtml ) ]
