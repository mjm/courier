module Data.User exposing (User, SubscriptionStatus(..), subscriptionStatus, isValidSubscription, avatarUrl, decoder)

import Date exposing (Date)
import Date.Extra as DateE
import Json.Decode as Decode exposing (Decoder, string, bool)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Util.Date


type alias User =
    { username : String
    , name : String
    , subscribed : Bool
    , subscriptionExpiresAt : Maybe Date
    , subscriptionRenewsAt : Maybe Date
    }


type SubscriptionStatus
    = NotSubscribed
    | Valid Date Date
    | Expired Date
    | Canceled Date


subscriptionStatus : User -> Date -> SubscriptionStatus
subscriptionStatus user now =
    case user.subscriptionExpiresAt of
        Just expiresAt ->
            case DateE.compare expiresAt now of
                LT ->
                    Expired expiresAt

                _ ->
                    case user.subscriptionRenewsAt of
                        Just renewsAt ->
                            Valid expiresAt renewsAt

                        Nothing ->
                            Canceled expiresAt

        Nothing ->
            NotSubscribed


isValidSubscription : User -> Date -> Bool
isValidSubscription user now =
    case subscriptionStatus user now of
        Valid _ _ ->
            True

        _ ->
            False


avatarUrl : User -> String
avatarUrl user =
    "https://avatars.io/twitter/" ++ user.username


decoder : Decoder User
decoder =
    decode User
        |> required "username" string
        |> required "name" string
        |> optional "subscribed" bool False
        |> optional "subscriptionExpiresAt" Util.Date.decoder Nothing
        |> optional "subscriptionRenewsAt" Util.Date.decoder Nothing
