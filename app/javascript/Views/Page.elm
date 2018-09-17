module Views.Page exposing (..)

import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.Icon exposing (..)


navbar : Maybe User -> Html msg
navbar user =
    nav [ class "navbar is-info" ]
        [ navbarBrand
        , navbarMenu user
        ]


navbarBrand : Html msg
navbarBrand =
    div [ class "navbar-brand" ]
        [ a
            [ class "navbar-item has-text-weight-bold is-size-5"
            , href "/"
            ]
            [ span [ class "icon is-medium" ]
                [ i [ class "fas fa-paper-plane" ] [] ]
            , span [] [ text "Courier" ]
            ]
        ]


navbarMenu : Maybe User -> Html msg
navbarMenu user =
    div [ class "navbar-menu" ]
        [ div [ class "navbar-end" ]
            [ profileNavbarItem user ]
        ]


profileNavbarItem : Maybe User -> Html msg
profileNavbarItem user =
    div [ class "navbar-item has-dropdown is-hoverable" ] <|
        case user of
            Just user ->
                [ a [ class "navbar-link" ]
                    [ icon Brand "twitter"
                    , span [ class "has-text-weight-semibold" ]
                        [ text user.name ]
                    ]
                , div [ class "navbar-dropdown" ]
                    [ a
                        [ class "navbar-item"
                        , href "/feeds"
                        ]
                        [ icon Solid "rss"
                        , span [] [ text "Your Feeds" ]
                        ]
                    , a
                        [ class "navbar-item"
                        , href "/account"
                        ]
                        [ icon Solid "user-circle"
                        , span [] [ text "Your Account" ]
                        ]
                    ]
                ]

            Nothing ->
                [ text "" ]


footer : Html msg
footer =
    Html.footer [ class "footer" ]
        [ div [ class "content has-text-centered" ]
            [ strong [] [ text "Courier" ]
            , text " is created by "
            , a [ href "https://mattmoriarity.com/" ] [ text "Matt Moriarity" ]
            , text "."
            ]
        ]
