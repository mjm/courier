module Page.Account.View exposing (view)

import Browser exposing (Document)
import Data.Account as Account exposing (Status(..))
import Data.User exposing (CardBrand(..))
import DateFormat.Relative exposing (relativeTime)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page
import Page.Account.Model exposing (Message(..), Model)
import Views.Icon exposing (..)


view : Model -> Document Message
view model =
    Page.view model.page <|
        div []
            [ h2 [ class "title has-text-centered" ] [ text "Your Account" ]
            , hr [] []
            , userForm model
            ]


userForm : Model -> Html Message
userForm model =
    div [ class "columns" ]
        [ div [ class "column is-10 is-offset-2" ]
            [ formField "Twitter User"
                [ p [ class "control" ]
                    [ p [ class "form-text" ]
                        [ a
                            [ href <| "https://twitter.com/" ++ model.page.user.username
                            , target "_blank"
                            ]
                            [ icon Brand "twitter"
                            , span []
                                [ text <|
                                    model.page.user.name
                                        ++ " ("
                                        ++ model.page.user.username
                                        ++ ")"
                                ]
                            ]
                        ]
                    ]
                ]
            , formField "Subscription" <|
                case Account.status model.page.user model.page.now of
                    NotSubscribed ->
                        [ p [ class "field is-grouped" ]
                            [ p [ class "control" ]
                                [ button
                                    [ class "button is-link"
                                    , onClick
                                        (case model.page.user.card of
                                            Just _ ->
                                                Resubscribe

                                            Nothing ->
                                                OpenPaymentForm
                                        )
                                    ]
                                    [ icon Solid "credit-card"
                                    , span [] [ text "Subscribe for $5/mo" ]
                                    ]
                                ]
                            ]
                        , p [ class "help" ]
                            [ text "Your tweets will not be posted automatically until you subscribe." ]
                        ]

                    Expired _ ->
                        [ p [ class "control" ]
                            [ p [ class "form-text" ]
                                [ span [ class "tag is-danger is-medium" ]
                                    [ icon Solid "calendar-times"
                                    , span [] [ text "Expired" ]
                                    ]
                                ]
                            ]
                        , p [ class "help" ]
                            [ text "Your tweets will not be posted automatically until you "
                            , a
                                [ onClick
                                    (case model.page.user.card of
                                        Just _ ->
                                            Resubscribe

                                        Nothing ->
                                            OpenPaymentForm
                                    )
                                , class "has-text-link"
                                ]
                                [ text "resubscribe" ]
                            , text "."
                            ]
                        ]

                    Canceled expiresAt ->
                        [ p [ class "control" ]
                            [ p [ class "form-text" ]
                                [ span [ class "tag is-light is-medium" ]
                                    [ icon Solid "times"
                                    , span [] [ text "Canceled" ]
                                    ]
                                ]
                            ]
                        , p [ class "help" ]
                            [ text "Your subscription will expire "
                            , strong [] [ text (relativeTime model.page.now expiresAt) ]
                            , text ". "
                            , a
                                [ onClick ReactivateSubscription
                                , class "has-text-link"
                                ]
                                [ text "Reactivate my subscription" ]
                            , text "."
                            ]
                        ]

                    Valid _ renewsAt ->
                        [ p [ class "control" ]
                            [ p [ class "form-text" ]
                                [ span [ class "tag is-primary is-medium" ]
                                    [ icon Solid "check"
                                    , span [] [ text "Active" ]
                                    ]
                                ]
                            ]
                        , p [ class "help" ]
                            [ text "Your subscription renews "
                            , strong [] [ text (relativeTime model.page.now renewsAt) ]
                            , text ". "
                            , a
                                [ onClick CancelSubscription
                                , class "has-text-danger"
                                ]
                                [ text "Cancel my subscription" ]
                            , text "."
                            ]
                        ]
            , formField "Payment Details"
                [ p [ class "control" ]
                    [ p [ class "form-text" ] <|
                        case model.page.user.card of
                            Just card ->
                                [ p []
                                    [ brandIcon card.brand
                                    , span []
                                        [ text " •••• "
                                        , text card.lastFour
                                        ]
                                    ]
                                , p []
                                    [ icon Solid "calendar-times"
                                    , text <|
                                        "Expires "
                                            ++ String.fromInt card.expMonth
                                            ++ " / "
                                            ++ String.fromInt card.expYear
                                    ]
                                ]

                            Nothing ->
                                [ text "No saved payment details" ]
                    ]
                ]
            ]
        ]


formField : String -> List (Html Message) -> Html Message
formField labelText hs =
    div [ class "field is-horizontal" ]
        [ div [ class "field-label is-normal" ]
            [ label [ class "label" ] [ text labelText ] ]
        , div [ class "field-body" ]
            [ div [ class "field" ] hs ]
        ]


brandIcon : CardBrand -> Html msg
brandIcon b =
    case b of
        Visa ->
            mediumIcon Brand "cc-visa"

        AmEx ->
            mediumIcon Brand "cc-amex"

        Mastercard ->
            mediumIcon Brand "cc-mastercard"

        Discover ->
            mediumIcon Brand "cc-discover"

        DinersClub ->
            mediumIcon Brand "cc-diners-club"

        JCB ->
            mediumIcon Brand "cc-jcb"

        Unknown _ ->
            mediumIcon Solid "credit-card"
