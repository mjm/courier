module Page.Account.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Page.Account.Model exposing (Model, Message(..))


view : Model -> Html Message
view model =
    div []
        [ Html.form []
            [ node "script"
                [ src "https://checkout.stripe.com/checkout.js"
                , class "stripe-button"
                , attribute "data-key" model.stripeKey
                , attribute "data-name" "Courier"
                , attribute "data-description" "Monthly autoposting subscription"
                , attribute "data-amount" "500"
                , attribute "data-label" "Subscribe"
                ]
                []
            ]
        ]
