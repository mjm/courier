module Data.Account exposing (Status(..), status, isActive)

import Data.User as User exposing (User)
import Date exposing (Date)
import Date.Extra as DateE


type Status
    = NotSubscribed
    | Valid Date Date
    | Expired Date
    | Canceled Date


status : User -> Date -> Status
status user now =
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


isActive : User -> Date -> Bool
isActive user now =
    case status user now of
        Valid _ _ ->
            True

        Canceled _ ->
            True

        _ ->
            False
