module Page.Feeds.View exposing (view)

import Data.Feed as Feed exposing (Feed, DraftFeed)
import Date exposing (Date)
import DateFormat.Relative exposing (relativeTime)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Events.Extra exposing (onClickPreventDefault)
import Page
import Page.Feeds.Model exposing (Model, Message(..))
import Views.Icon exposing (..)
import Util.URL as URL


view : Model -> Html Message
view model =
    Page.view model.page <|
        div []
            [ h1 [ class "title has-text-centered" ] [ text "Your Feeds" ]
            , p [ class "has-text-centered" ] [ text "Your Courier will periodically check these feeds for new posts to send to Twitter." ]
            , hr [] []
            , div [ class "columns" ]
                [ div [ class "column is-8 is-offset-2" ]
                    [ feeds model.feeds model.page.now
                    , addFeedView model
                    ]
                ]
            ]


feeds : List Feed -> Date -> Html Message
feeds fs now =
    case fs of
        [] ->
            p [ class "has-text-centered" ]
                [ text "You don't have any feeds registered." ]

        fs ->
            table [ class "table is-fullwidth" ]
                [ List.map (feedRow now) fs |> tbody [] ]


feedRow : Date -> Feed -> Html Message
feedRow now feed =
    tr []
        [ td
            [ style
                [ ( "width", "1rem" )
                , ( "padding-right", "0" )
                ]
            ]
            [ span [ class "icon is-medium has-text-link" ]
                [ i [ class "fas fa-rss fa-lg" ] [] ]
            ]
        , td []
            [ h1 [ class "title is-4" ]
                [ span [] [ text (Feed.displayName feed) ]
                ]
            , h2 [ class "subtitle is-6" ]
                [ a
                    [ href feed.homePageUrl
                    , rel "noopener"
                    , target "_blank"
                    ]
                    [ span [ class "icon has-text-grey-light" ] [ i [ class "fas fa-home" ] [] ]
                    , span [ class "has-text-grey" ] [ text (URL.displayUrl feed.homePageUrl) ]
                    ]
                ]
            ]
        , td
            [ class "has-text-right has-text-grey is-size-7"
            , style [ ( "vertical-align", "middle" ) ]
            ]
            [ case feed.refreshedAt of
                Just date ->
                    text ("last checked " ++ (relativeTime now date))

                Nothing ->
                    text ""
            ]
        , td
            [ class "has-text-right"
            , style [ ( "vertical-align", "middle" ) ]
            ]
            [ feedDropdown feed ]
        ]


feedDropdown : Feed -> Html Message
feedDropdown feed =
    let
        autopost =
            feed.settings.autopost
    in
        div [ class "dropdown is-hoverable" ]
            [ div [ class "dropdown-trigger" ]
                [ button [ class "button is-white" ]
                    [ icon Solid "bars" ]
                ]
            , div [ class "dropdown-menu has-text-left" ]
                [ div [ class "dropdown-content" ]
                    [ a
                        [ class "dropdown-item"
                        , onClick (RefreshFeed feed)
                        ]
                        [ icon Solid "sync-alt"
                        , span [] [ text "Refresh Posts" ]
                        ]
                    , a
                        [ class "dropdown-item"
                        , onClick (UpdateAutoposting feed (not autopost))
                        ]
                        [ span []
                            [ icon Solid
                                (if autopost then
                                    "comment-slash"
                                 else
                                    "comment"
                                )
                            , text
                                (if autopost then
                                    "Turn Off Autoposting"
                                 else
                                    "Turn On Autoposting"
                                )
                            ]
                        ]
                    , a
                        [ class "dropdown-item has-text-danger"
                        , onClick (DeleteFeed feed)
                        ]
                        [ icon Solid "trash"
                        , span [] [ text "Delete Feed" ]
                        ]
                    ]
                ]
            ]


addFeedView : Model -> Html Message
addFeedView model =
    case model.draftFeed of
        Just feed ->
            addFeedForm feed

        Nothing ->
            addFeedButton


addFeedButton : Html Message
addFeedButton =
    p [ class "has-text-centered" ]
        [ button
            [ class "button is-rounded is-primary is-large"
            , onClick (SetAddingFeed True)
            ]
            [ icon Solid "plus-circle"
            , span [] [ text "Add Feed" ]
            ]
        ]


addFeedForm : DraftFeed -> Html Message
addFeedForm feed =
    Html.form
        [ action "javascript:void(0);"
        , onSubmit AddFeed
        ]
        [ div [ class "field" ]
            [ div [ class "control" ]
                [ input
                    [ id "add-feed-url"
                    , type_ "text"
                    , class "input is-medium"
                    , placeholder "Feed URL"
                    , onInput SetDraftFeedUrl
                    , value feed.url
                    ]
                    []
                ]
            ]
        , div [ class "field is-grouped is-grouped-right" ]
            [ p [ class "control" ]
                [ button
                    [ class "button is-light"
                    , onClickPreventDefault (SetAddingFeed False)
                    , type_ "button"
                    ]
                    [ text "Cancel" ]
                ]
            , p [ class "control" ]
                [ button
                    [ class "button is-primary"
                    , type_ "submit"
                    ]
                    [ text "Add Feed" ]
                ]
            ]
        ]
