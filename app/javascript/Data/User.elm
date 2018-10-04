module Data.User exposing (CardBrand(..), User, avatarUrl, decoder, empty)

import Iso8601
import Json.Decode as Decode exposing (Decoder, bool, int, maybe, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Time exposing (Posix)


type alias User =
    { username : String
    , name : String
    , subscribed : Bool
    , subscriptionExpiresAt : Maybe Posix
    , subscriptionRenewsAt : Maybe Posix
    , card : Maybe Card
    }


type alias Card =
    { brand : CardBrand
    , lastFour : String
    , expMonth : Int
    , expYear : Int
    }


type CardBrand
    = Visa
    | AmEx
    | Mastercard
    | Discover
    | DinersClub
    | JCB
    | Unknown String


empty : User
empty =
    User "" "" False Nothing Nothing Nothing


avatarUrl : User -> String
avatarUrl user =
    "https://avatars.io/twitter/" ++ user.username


decoder : Decoder User
decoder =
    succeed User
        |> required "username" string
        |> required "name" string
        |> optional "subscribed" bool False
        |> optional "subscriptionExpiresAt" (maybe Iso8601.decoder) Nothing
        |> optional "subscriptionRenewsAt" (maybe Iso8601.decoder) Nothing
        |> optional "card" (maybe cardDecoder) Nothing


cardDecoder : Decoder Card
cardDecoder =
    succeed Card
        |> optional "brand" brandDecoder (Unknown "")
        |> optional "lastFour" string ""
        |> optional "expMonth" int 0
        |> optional "expYear" int 0


brandDecoder : Decoder CardBrand
brandDecoder =
    Decode.map
        (\x ->
            case x of
                "Visa" ->
                    Visa

                "American Express" ->
                    AmEx

                "MasterCard" ->
                    Mastercard

                "Discover" ->
                    Discover

                "Diners Club" ->
                    DinersClub

                "JCB" ->
                    JCB

                _ ->
                    Unknown x
        )
        string
