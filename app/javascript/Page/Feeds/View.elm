module Page.Feeds.View exposing (view)

import Browser exposing (Document)
import Data.Feed as Feed exposing (DraftFeed, Feed, Status(..))
import DateFormat.Relative exposing (relativeTime)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Page
import Page.Feeds.Model exposing (Message(..), Model)
import Time exposing (Posix)
import Util.URL as URL
import Views.Icon exposing (..)


view : Model -> Document Message
view model =
    Page.view model.page <|
        div []
            [ h1 [ class "title has-text-centered" ]
                [ text "Your Feeds" ]
            , p [ class "has-text-centered" ]
                [ text "Your Courier will periodically check these feeds for new posts to send to Twitter." ]
            , hr [] []
            , div [ class "columns" ]
                [ div [ class "column is-8 is-offset-2" ]
                    [ feedsList model.feeds model.page.now
                    , addFeedView model
                    ]
                ]
            ]


feedsList : List Feed -> Posix -> Html Message
feedsList feeds now =
    case feeds of
        [] ->
            p [ class "has-text-centered" ]
                [ text "You don't have any feeds registered." ]

        fs ->
            div [] <|
                List.map (feedRow now) fs


feedRow : Posix -> Feed -> Html Message
feedRow now feed =
    div []
        [ article [ class "media" ]
            [ div [ class "media-content" ]
                [ div [ class "content is-size-5 is-size-6-mobile" ]
                    [ span [ class "has-text-link" ] [ icon Solid "rss" ]
                    , strong [] [ text (Feed.displayName feed) ]
                    ]
                ]
            , div [ class "media-right" ]
                [ feedDropdown feed ]
            ]
        , div [ class "level is-mobile has-text-grey is-size-7-mobile" ]
            [ div [ class "level-left" ]
                [ div [ class "level-item" ]
                    [ a
                        [ href feed.homePageUrl
                        , rel "noopener"
                        , target "_blank"
                        , class "has-text-grey"
                        ]
                        [ icon Solid "home"
                        , span [] [ text (URL.displayUrl feed.homePageUrl) ]
                        ]
                    ]
                , div [ class "level-item" ]
                    [ refreshedIcon feed.status
                    , refreshedLabel feed now
                    ]
                ]
            ]
        , hr [] []
        ]


refreshedIcon : Status -> Html msg
refreshedIcon status =
    case status of
        Succeeded ->
            icon Solid "sync"

        Refreshing ->
            icon Solid "sync fa-spin"

        Failed ->
            icon Solid "exclamation-triangle"


refreshedLabel : Feed -> Posix -> Html msg
refreshedLabel feed now =
    span [ title (Maybe.withDefault "" feed.refreshMessage) ]
        [ case ( feed.status, feed.refreshedAt ) of
            ( Succeeded, Just date ) ->
                text ("checked " ++ relativeTime now date)

            ( Failed, Just date ) ->
                text ("failed to get posts" ++ relativeTime now date)

            ( Refreshing, _ ) ->
                text "refreshing now"

            ( _, Nothing ) ->
                text ""
        ]


feedDropdown : Feed -> Html Message
feedDropdown feed =
    let
        autopost =
            feed.settings.autopost
    in
    div [ class "dropdown is-hoverable is-right" ]
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
                    , span [] [ text "Check for New Posts" ]
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
                    , autofocus True
                    ]
                    []
                ]
            ]
        , div [ class "field is-grouped is-grouped-right" ]
            [ p [ class "control" ]
                [ button
                    [ class "button is-light"
                    , onClick (SetAddingFeed False)
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
