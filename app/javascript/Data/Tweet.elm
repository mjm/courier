module Data.Tweet exposing (PostInfo, Status(..), Tweet, compare, decoder, listDecoder, past, upcoming, update)

import Data.Feed as Feed exposing (Feed)
import Iso8601
import Json.Decode as Decode exposing (Decoder, int, maybe, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Time exposing (Posix)
import Util.Editable as Editable exposing (Editable)


type Status
    = Draft
    | Canceled
    | Posted


type alias Tweet =
    { id : Int
    , body : String
    , post : PostInfo
    , status : Status
    , postedAt : Maybe Posix
    , tweetId : Maybe String
    , willPostAt : Maybe Posix
    , mediaUrls : List String
    , feed : Feed
    }


type alias PostInfo =
    { id : Int
    , url : String
    , publishedAt : Maybe Posix
    , modifiedAt : Maybe Posix
    }


decoder : Decoder Tweet
decoder =
    succeed Tweet
        |> required "id" int
        |> required "body" string
        |> required "post" postDecoder
        |> optional "status" (Decode.map statusFromString string) Draft
        |> optional "postedAt" (maybe Iso8601.decoder) Nothing
        |> optional "postedTweetId" (maybe string) Nothing
        |> optional "willPostAt" (maybe Iso8601.decoder) Nothing
        |> optional "mediaUrls" (Decode.list string) []
        |> required "feed" Feed.decoder


postDecoder : Decoder PostInfo
postDecoder =
    succeed PostInfo
        |> required "id" int
        |> required "url" string
        |> optional "publishedAt" (maybe Iso8601.decoder) Nothing
        |> optional "modifiedAt" (maybe Iso8601.decoder) Nothing


listDecoder : Decoder (List Tweet)
listDecoder =
    Decode.list decoder


statusFromString : String -> Status
statusFromString str =
    case str of
        "CANCELED" ->
            Canceled

        "POSTED" ->
            Posted

        _ ->
            Draft


update : Tweet -> Tweet -> Tweet
update existing new =
    if existing.id == new.id then
        new

    else
        existing


compare : Tweet -> Tweet -> Order
compare a b =
    case ( a.post.publishedAt, b.post.publishedAt ) of
        ( Just x, Just y ) ->
            Basics.compare
                (Time.posixToMillis y)
                (Time.posixToMillis x)

        ( Just _, Nothing ) ->
            LT

        ( Nothing, Just _ ) ->
            GT

        ( Nothing, Nothing ) ->
            EQ


upcoming : List (Editable Tweet) -> List (Editable Tweet)
upcoming =
    Editable.filter (\t -> t.status == Draft)


past : List (Editable Tweet) -> List (Editable Tweet)
past =
    Editable.filter (\t -> t.status /= Draft)
