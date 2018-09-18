module Page.Posts.View exposing (view)

import Data.Tweet exposing (Tweet, PostInfo, Status(..))
import Data.User as User exposing (User, SubscriptionStatus(..))
import Date exposing (Date)
import DateFormat.Relative exposing (relativeTime)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Page.Posts.Model exposing (Model, Message(..))
import Time
import Views.Error as Error
import Views.Icon exposing (..)
import Views.Page as Page
import Util.Editable as Editable exposing (Editable(..))


view : Model -> Html Message
view model =
    [ Page.navbar (Just model.user)
    , Error.errors DismissError model.errors
    , section [ class "section" ]
        [ div [ class "container" ]
            [ div []
                [ h2 [ class "title has-text-centered" ] [ text "Your Tweets" ]
                , hr [] []
                , subscriptionMessage model.user model.now
                , List.map (postEntry model.user model.now) model.tweets |> div []
                ]
            ]
        ]
    , Page.footer
    ]
        |> div []


subscriptionMessage : User -> Date -> Html Message
subscriptionMessage user now =
    case User.subscriptionStatus user now of
        NotSubscribed ->
            div [ class "notification is-warning has-text-centered" ]
                [ text "You do not have a paid subscription to Courier, so you can only preview the tweets that would be posted for you."
                , br [] []
                , text "You can sign up at any time from the "
                , a [ href "/account" ] [ text "Your Account" ]
                , text " page."
                ]

        _ ->
            text ""


postEntry : User -> Date -> Editable Tweet -> Html Message
postEntry user now tweet =
    div []
        [ div [ class "columns" ]
            [ div [ class "column is-two-thirds" ]
                [ tweetCard user tweet now ]
            , div [ class "column is-one-third" ]
                [ postDetails tweet now ]
            ]
        ]


postDetails : Editable Tweet -> Date -> Html Message
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
                        [ text "View on your site" ]
                    ]
                ]
            ]


tweetCard : User -> Editable Tweet -> Date -> Html Message
tweetCard user postTweet now =
    case postTweet of
        Viewing tweet ->
            viewTweetCard user tweet now

        Editing _ tweet ->
            editTweetCard user tweet

        Saving _ tweet ->
            savingTweetCard user tweet.post


viewTweetCard : User -> Tweet -> Date -> Html Message
viewTweetCard user tweet now =
    article [ class "card" ]
        [ div [ class "card-content" ]
            [ tweetUserInfo user tweet.post
            , p [ style [ ( "white-space", "pre-line" ) ] ] [ text tweet.body ]
            ]
        , footer [ class "card-footer" ] <|
            case tweet.status of
                Draft ->
                    draftActions tweet now

                Canceled ->
                    canceledActions tweet

                Posted ->
                    postedActions tweet now
        ]


editTweetCard : User -> Tweet -> Html Message
editTweetCard user tweet =
    Html.form [ action "javascript:void(0);" ]
        [ article [ class "card" ]
            [ div [ class "card-content" ]
                [ tweetUserInfo user tweet.post
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
            , footer [ class "card-footer" ] <| editActions tweet
            ]
        ]


savingTweetCard : User -> PostInfo -> Html Message
savingTweetCard user post =
    article [ class "card" ]
        [ div [ class "card-content" ]
            [ tweetUserInfo user post
            , p [ class "is-size-5 has-text-centered" ]
                [ span [ class "icon is-medium rotating" ] [ i [ class "fas fa-spinner" ] [] ]
                , span [] [ text "Saving changes..." ]
                ]
            ]
        ]


draftActions : Tweet -> Date -> List (Html Message)
draftActions tweet now =
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
    , a
        [ onClick <| SubmitTweet tweet
        , class "card-footer-item"
        ]
        [ icon Solid "share"
        , span [] [ text "Post Now" ]
        , willPostETA tweet now
        ]
    ]


willPostETA : Tweet -> Date -> Html msg
willPostETA tweet now =
    case tweet.willPostAt of
        Just date ->
            let
                eta =
                    relativeETA date now
            in
                span [ class "is-size-7 has-text-grey" ]
                    [ text <| " (ETA " ++ eta ++ ")" ]

        Nothing ->
            text ""


relativeETA : Date -> Date -> String
relativeETA date now =
    let
        time =
            (Date.toTime date) - (Date.toTime now)

        stringify =
            (\x -> toString (round x))
    in
        if time < 0 then
            "soon"
        else if time < Time.minute then
            (stringify (Time.inSeconds time)) ++ "s"
        else if time < Time.hour then
            (stringify (Time.inMinutes time)) ++ "m"
        else
            (stringify (Time.inHours time)) ++ "h"


canceledActions : Tweet -> List (Html Message)
canceledActions tweet =
    [ div [ class "card-footer-item" ]
        [ span [] [ text "Canceled. " ]
        , a [ onClick (UncancelTweet tweet) ] [ text "Undo?" ]
        ]
    ]


postedActions : Tweet -> Date -> List (Html msg)
postedActions tweet now =
    [ div [ class "card-footer-item" ]
        [ icon Solid "check-circle"
        , span []
            [ text "Posted"
            , case tweet.postedAt of
                Just date ->
                    text (" " ++ (relativeTime now date))

                Nothing ->
                    text ""
            , text ". "
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


editActions : Tweet -> List (Html Message)
editActions tweet =
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
    , a
        [ class "card-footer-item"
        , onClick (SaveTweet tweet True)
        ]
        [ span [] [ text "Post Now " ] ]
    ]


tweetUserInfo : User -> PostInfo -> Html Message
tweetUserInfo user post =
    header [ class "media" ]
        [ div [ class "media-left" ]
            [ figure [ class "image is-48x48" ]
                [ img [ src (User.avatarUrl user), class "is-rounded" ] [] ]
            ]
        , div [ class "media-content" ]
            [ h1 [ class "title is-5" ] [ text user.name ]
            , h2 [ class "subtitle is-6 has-text-grey" ] [ text <| "@" ++ user.username ]
            ]
        ]
