module Views.Error exposing (error, errors)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


errors : (String -> msg) -> List String -> Html msg
errors msg errs =
    if List.isEmpty errs then
        text ""

    else
        section [ class "section" ]
            [ List.map (error msg) errs |> div [ class "container" ] ]


error : (String -> msg) -> String -> Html msg
error msg err =
    div [ class "notification is-danger" ]
        [ button [ class "delete", onClick (msg err) ] []
        , span [ class "icon is-medium" ] [ i [ class "fas fa-exclamation-circle fa-lg" ] [] ]
        , span [] [ text err ]
        ]
