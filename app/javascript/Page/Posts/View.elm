module Page.Posts.View exposing (view)

import Browser exposing (Document)
import Data.Account as Account
import Data.Feed as Feed
import Data.Tweet as Tweet exposing (PostInfo, Status(..), Tweet)
import Data.User as User exposing (User)
import DateFormat.Relative exposing (relativeTime)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Page
import Page.Posts.Model exposing (Message(..), Model)
import Time exposing (Posix)
import Util.Editable as Editable exposing (Editable(..))
import Views.Icon exposing (..)
import Views.Linkify exposing (linkify)


view : Model -> Document Message
view model =
    let
        upcoming =
            Tweet.upcoming model.tweets

        past =
            Tweet.past model.tweets
    in
    Page.view model.page <|
        div []
            [ subscriptionMessage model.page.user model.page.now
            , h2 [ class "title has-text-centered" ]
                [ text "Upcoming Tweets" ]
            , hr [] []
            , if List.isEmpty upcoming then
                p [ class "has-text-centered" ]
                    [ text "You don't have any tweets waiting to be posted." ]

              else
                div [] <|
                    List.map
                        (postEntry model.page.user model.page.now)
                        (List.take 10 upcoming)
            , h2 [ class "title has-text-centered has-top-margin" ]
                [ text "Past Tweets" ]
            , hr [] []
            , if List.isEmpty past then
                p [ class "has-text-centered" ]
                    [ text "You haven't posted any tweets with Courier." ]

              else
                div [] <|
                    List.map
                        (postEntry model.page.user model.page.now)
                        past
            ]


subscriptionMessage : User -> Posix -> Html Message
subscriptionMessage user now =
    if Account.isActive user now then
        text ""

    else
        div [ class "notification is-warning has-text-centered" ]
            [ text "You do not have a paid subscription to Courier, so you can only preview the tweets that would be posted for you."
            , br [] []
            , text "You can sign up at any time from the "
            , a [ href "/account" ] [ text "Your Account" ]
            , text " page."
            ]


postEntry : User -> Posix -> Editable Tweet -> Html Message
postEntry user now tweet =
    div []
        [ div [ class "columns" ]
            [ div [ class "column is-two-thirds" ]
                [ tweetCard user tweet now ]
            , div [ class "column is-one-third" ]
                [ postDetails tweet now ]
            ]
        ]


postDetails : Editable Tweet -> Posix -> Html Message
postDetails tweet now =
    let
        t =
            Editable.value tweet

        published =
            Maybe.map (relativeTime now) t.post.publishedAt
                |> Maybe.withDefault "never"

        modified =
            if t.post.publishedAt == t.post.modifiedAt then
                Nothing

            else
                Maybe.map (relativeTime now) t.post.modifiedAt
    in
    p []
        [ ul [ class "fa-ul" ]
            [ li []
                [ span [ class "fa-li" ]
                    [ i [ class "fas fa-calendar-alt" ] [] ]
                , text ("Published " ++ published)
                ]
            , case modified of
                Nothing ->
                    text ""

                Just m ->
                    li []
                        [ span [ class "fa-li" ]
                            [ i [ class "fas fa-calendar-plus" ] [] ]
                        , text ("Updated " ++ m)
                        ]
            , li []
                [ span [ class "fa-li" ]
                    [ i [ class "fas fa-external-link-square-alt" ] [] ]
                , a [ href t.post.url, rel "noopener", target "_blank" ]
                    [ text <| "View on " ++ Feed.displayName t.feed ]
                ]
            ]
        ]


tweetCard : User -> Editable Tweet -> Posix -> Html Message
tweetCard user postTweet now =
    case postTweet of
        Viewing tweet ->
            viewTweetCard user tweet now

        Editing _ tweet ->
            editTweetCard user tweet now

        Saving _ tweet ->
            savingTweetCard user tweet


viewTweetCard : User -> Tweet -> Posix -> Html Message
viewTweetCard user tweet now =
    article
        [ classList
            [ ( "card", True )
            , ( "has-background-light", useLightBackground tweet )
            ]
        ]
        [ div
            [ classList
                [ ( "card-content", True )
                , ( "is-grayscale", useLightBackground tweet )
                ]
            ]
            ([ tweetUserInfo user tweet
             , p [ class "tweet-content" ] (linkify tweet.body)
             ]
                ++ List.map viewMediaItem tweet.mediaUrls
            )
        , footer [ class "card-footer" ] <|
            case tweet.status of
                Draft ->
                    draftActions user tweet now

                Canceled ->
                    canceledActions tweet

                Posted ->
                    postedActions tweet now
        ]


useLightBackground : Tweet -> Bool
useLightBackground t =
    case t.status of
        Canceled ->
            True

        _ ->
            False


viewMediaItem : String -> Html Message
viewMediaItem url =
    figure [ class "image is-128x128" ]
        [ img [ src url ] [] ]


editTweetCard : User -> Tweet -> Posix -> Html Message
editTweetCard user tweet now =
    Html.form [ action "javascript:void(0);" ]
        [ article [ class "card" ]
            [ div [ class "card-content" ]
                [ tweetUserInfo user tweet
                , div [ class "field" ]
                    [ div [ class "control" ]
                        [ textarea
                            [ class "textarea"
                            , autofocus True
                            , onInput (SetTweetBody tweet)
                            , value tweet.body
                            ]
                            []
                        ]
                    ]
                ]
            , footer [ class "card-footer" ] <| editActions user tweet now
            ]
        ]


savingTweetCard : User -> Tweet -> Html Message
savingTweetCard user tweet =
    article [ class "card" ]
        [ div [ class "card-content" ]
            [ tweetUserInfo user tweet
            , p [ class "is-size-5 has-text-centered" ]
                [ span [ class "icon is-medium" ]
                    [ i [ class "fas fa-spinner fa-spin" ] [] ]
                , span [] [ text "Saving changes..." ]
                ]
            ]
        ]


draftActions : User -> Tweet -> Posix -> List (Html Message)
draftActions user tweet now =
    [ a
        [ onClick <| CancelTweet tweet
        , class "card-footer-item has-text-danger"
        ]
        [ icon Solid "ban", span [] [ text "Don't Post" ] ]
    , a
        [ onClick <| EditTweet tweet
        , class "card-footer-item has-text-primary"
        ]
        [ icon Solid "pencil-alt", span [] [ text "Edit Tweet" ] ]
    ]
        ++ (if Account.isActive user now then
                [ a
                    [ onClick <| SubmitTweet tweet
                    , class "card-footer-item"
                    ]
                    [ icon Solid "share"
                    , span [] [ text "Post Now" ]
                    , willPostETA tweet now
                    ]
                ]

            else
                []
           )


willPostETA : Tweet -> Posix -> Html msg
willPostETA tweet now =
    case tweet.willPostAt of
        Just date ->
            let
                eta =
                    relativeETA date now
            in
            span [ class "is-size-7 has-text-grey" ]
                [ text <| "\u{00A0}(ETA " ++ eta ++ ")" ]

        Nothing ->
            text ""


relativeETA : Posix -> Posix -> String
relativeETA date now =
    let
        millis =
            Time.posixToMillis date - Time.posixToMillis now

        seconds =
            toFloat millis / 1000

        format =
            \factor -> String.fromInt (round (seconds / factor))
    in
    if seconds < 0 then
        "soon"

    else if seconds < 60 then
        format 1.0 ++ "s"

    else if seconds < 3600 then
        format 60.0 ++ "m"

    else
        format 3600.0 ++ "h"


canceledActions : Tweet -> List (Html Message)
canceledActions tweet =
    [ div [ class "card-footer-item" ]
        [ span [] [ text "Canceled.\u{00A0}" ]
        , a [ onClick (UncancelTweet tweet) ] [ text "Undo?" ]
        ]
    ]


postedActions : Tweet -> Posix -> List (Html msg)
postedActions tweet now =
    [ div [ class "card-footer-item" ]
        [ icon Solid "check-circle"
        , span []
            [ text "Posted"
            , case tweet.postedAt of
                Just date ->
                    text (" " ++ relativeTime now date)

                Nothing ->
                    text ""
            , text ".\u{00A0}"
            ]
        , case tweet.tweetId of
            Just tweetId ->
                a
                    [ href ("https://twitter.com/user/status/" ++ tweetId)
                    , target "_blank"
                    ]
                    [ text "View on Twitter" ]

            Nothing ->
                text ""
        ]
    ]


editActions : User -> Tweet -> Posix -> List (Html Message)
editActions user tweet now =
    [ a
        [ class "card-footer-item has-text-danger"
        , onClick (CancelEditTweet tweet)
        ]
        [ icon Solid "ban", span [] [ text "Cancel" ] ]
    , a
        [ class "card-footer-item"
        , onClick (SaveTweet tweet False)
        ]
        [ span [] [ text "Save Draft" ] ]
    ]
        ++ (if Account.isActive user now then
                [ a
                    [ class "card-footer-item"
                    , onClick (SaveTweet tweet True)
                    ]
                    [ span [] [ text "Post Now " ] ]
                ]

            else
                []
           )


tweetUserInfo : User -> Tweet -> Html Message
tweetUserInfo user tweet =
    header [ class "media" ]
        [ div [ class "media-left" ]
            [ figure
                [ class "image is-48x48" ]
                [ img [ src (User.avatarUrl user), class "is-rounded" ] [] ]
            ]
        , div [ class "media-content" ]
            [ h1 [ class "title is-5" ] [ text user.name ]
            , h2 [ class "subtitle is-6 has-text-grey" ] [ text <| "@" ++ user.username ]
            ]
        ]
