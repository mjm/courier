module Page.Account.View exposing (view)

import Data.Account as Account exposing (Status(..))
import DateFormat.Relative exposing (relativeTime)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page
import Page.Account.Model exposing (Message(..), Model)
import Views.Icon exposing (..)


view : Model -> Html Message
view model =
    Page.view model.page <|
        div []
            [ h2 [ class "title has-text-centered" ] [ text "Your Account" ]
            , hr [] []
            , subscriptionInfo model
            ]


subscriptionInfo : Model -> Html Message
subscriptionInfo model =
    case Account.status model.page.user model.page.now of
        Expired expiresAt ->
            p [ class "has-text-centered" ]
                [ text "Oh no! Your subscription to Courier has "
                , strong [] [ text "expired" ]
                , text "."
                ]

        Canceled expiresAt ->
            div [ class "content" ]
                [ p [ class "has-text-centered" ]
                    [ text "Your subscription has been canceled, but you can still use Courier until it expires." ]
                , p [ class "has-text-centered" ]
                    [ text "Your subscription will expire "
                    , strong [] [ text (relativeTime model.page.now expiresAt) ]
                    , text "."
                    ]
                , p [ class "has-text-centered" ]
                    [ button
                        [ onClick ReactivateSubscription
                        , class "button is-primary"
                        ]
                        [ span [] [ text "Reactivate My Subscription" ] ]
                    ]
                ]

        Valid _ renewsAt ->
            div [ class "content" ]
                [ p [ class "has-text-centered" ]
                    [ text "You have a subscription to Courier! Happy posting!" ]
                , p [ class "has-text-centered" ]
                    [ text "Your subscription will renew "
                    , strong [] [ text (relativeTime model.page.now renewsAt) ]
                    , text "."
                    ]
                , p [ class "has-text-centered" ]
                    [ button
                        [ onClick CancelSubscription
                        , class "button is-danger"
                        ]
                        [ icon Solid "ban"
                        , span [] [ text "Cancel My Subscription" ]
                        ]
                    ]
                ]

        NotSubscribed ->
            div [ class "content" ]
                [ p [ class "has-text-centered" ]
                    [ text "You have not subscribed to Courier yet. Your tweets will not be posted automatically until you subscribe." ]
                , p [ class "has-text-centered" ] [ stripeButton model ]
                ]


stripeButton : Model -> Html Message
stripeButton model =
    Html.form
        [ action "/subscribe"
        , method "POST"
        ]
        [ node "script"
            [ src "https://checkout.stripe.com/checkout.js"
            , class "stripe-button"
            , attribute "data-key" model.stripeKey
            , attribute "data-name" "Courier"
            , attribute "data-description" "Monthly autoposting subscription"
            , attribute "data-amount" "500"
            , attribute "data-label" "Subscribe"
            , attribute "data-zip-code" "true"
            ]
            []
        , button [ type_ "submit", class "button is-link is-medium" ]
            [ icon Solid "credit-card"
            , span [] [ text "Subscribe to Courier for $5/mo" ]
            ]
        ]
