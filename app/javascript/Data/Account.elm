module Data.Account exposing (Status(..), isActive, status)

import Data.User as User exposing (User)
import Time exposing (Posix)


type Status
    = NotSubscribed
    | Valid Posix Posix
    | Expired Posix
    | Canceled Posix


status : User -> Posix -> Status
status user now =
    case user.subscriptionExpiresAt of
        Just expiresAt ->
            if Time.posixToMillis expiresAt < Time.posixToMillis now then
                Expired expiresAt

            else
                case user.subscriptionRenewsAt of
                    Just renewsAt ->
                        Valid expiresAt renewsAt

                    Nothing ->
                        Canceled expiresAt

        Nothing ->
            NotSubscribed


isActive : User -> Posix -> Bool
isActive user now =
    case status user now of
        Valid _ _ ->
            True

        Canceled _ ->
            True

        _ ->
            False
