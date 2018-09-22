module Views.Modal exposing (Modal, modal)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)


type alias Modal msg =
    { title : String
    , body : String
    , confirmText : String
    , confirmMsg : msg
    , dismissMsg : msg
    }


modal : Maybe (Modal msg) -> Html msg
modal modal =
    case modal of
        Just modal ->
            div [ class "modal is-active" ]
                [ div [ class "modal-background" ] []
                , div [ class "modal-card" ]
                    [ header [ class "modal-card-head" ]
                        [ p [ class "modal-card-title is-size-5" ]
                            [ text modal.title ]
                        ]
                    , section [ class "modal-card-body" ]
                        [ p [] [ text modal.body ] ]
                    , footer [ class "modal-card-foot" ]
                        [ button
                            [ class "button is-danger"
                            , onClick modal.confirmMsg
                            ]
                            [ text modal.confirmText ]
                        , button
                            [ class "button"
                            , onClick modal.dismissMsg
                            ]
                            [ text "Cancel" ]
                        ]
                    ]
                ]

        Nothing ->
            text ""
