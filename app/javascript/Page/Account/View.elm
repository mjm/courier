module Page.Account.View exposing (view)

import Data.User as User exposing (SubscriptionStatus(..))
import DateFormat.Relative exposing (relativeTime)
import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Account.Model exposing (Model, Message(..))
import Views.Icon exposing (..)
import Views.Page as Page


view : Model -> Html Message
view model =
    div []
        [ Page.navbar (Just model.user)
        , section [ class "section" ]
            [ div [ class "container" ]
                [ div []
                    [ h2 [ class "title has-text-centered" ] [ text "Your Account" ]
                    , hr [] []
                    , subscriptionInfo model
                    ]
                ]
            ]
        , Page.footer
        ]


subscriptionInfo : Model -> Html Message
subscriptionInfo model =
    case User.subscriptionStatus model.user model.now of
        Expired expiresAt ->
            p [ class "has-text-centered" ]
                [ text "Oh no! Your subscription to Courier has "
                , strong [] [ text "expired" ]
                , text "."
                ]

        Valid expiresAt ->
            div [ class "content" ]
                [ p [ class "has-text-centered" ]
                    [ text "You have a subscription to Courier! Happy posting!" ]
                , p [ class "has-text-centered" ]
                    [ text "Your subscription will renew "
                    , strong [] [ text (relativeTime model.now expiresAt) ]
                    , text "."
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
