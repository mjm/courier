module Page.Posts.View exposing (view)

import Data.Post exposing (Post)
import Data.PostTweet exposing (PostTweet)
import Data.Tweet exposing (Tweet, Status(..))
import Data.User as User exposing (User)
import Date exposing (Date)
import DateFormat.Relative exposing (relativeTime)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Page.Posts.Model exposing (Model)
import Page.Posts.Update exposing (Message(..))
import Views.Icon exposing (..)
import Views.Page as Page
import Util.Editable as Editable exposing (Editable(..))


view : Model -> Html Message
view model =
    [ Page.navbar (Just model.user)
    , section [ class "section" ]
        [ div [ class "container" ]
            [ div []
                [ h2 [ class "title has-text-centered" ] [ text "Your Tweets" ]
                , hr [] []
                , List.map (postEntry model.user model.now) model.tweets |> div []
                ]
            ]
        ]
    , Page.footer
    ]
        |> div []


postEntry : User -> Date -> Editable PostTweet -> Html Message
postEntry user now tweet =
    div []
        [ div [ class "columns" ]
            [ div [ class "column is-two-thirds" ]
                [ tweetCard user tweet ]
            , div [ class "column is-one-third" ]
                [ postDetails tweet now ]
            ]
        ]


postDetails : Editable PostTweet -> Date -> Html Message
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


tweetCard : User -> Editable PostTweet -> Html Message
tweetCard user postTweet =
    case postTweet of
        Viewing tweet ->
            viewTweetCard user tweet

        Editing _ tweet ->
            editTweetCard user tweet

        Saving _ tweet ->
            savingTweetCard user tweet.post


viewTweetCard : User -> PostTweet -> Html Message
viewTweetCard user tweet =
    article [ class "card" ]
        [ div [ class "card-content" ]
            [ tweetUserInfo user tweet.post
            , p [] [ text tweet.tweet.body ]
            ]
        , footer [ class "card-footer" ] <|
            case tweet.tweet.status of
                Draft ->
                    draftActions tweet.tweet

                Canceled ->
                    canceledActions tweet.tweet

                Posted ->
                    postedActions tweet.tweet
        ]


editTweetCard : User -> PostTweet -> Html Message
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
                            , onInput (SetTweetBody tweet.tweet)
                            , value tweet.tweet.body
                            ]
                            []
                        ]
                    ]
                ]
            , footer [ class "card-footer" ] <| editActions tweet.tweet
            ]
        ]


savingTweetCard : User -> Post -> Html Message
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


draftActions : Tweet -> List (Html Message)
draftActions tweet =
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
    , a [ class "card-footer-item" ]
        [ icon Solid "share", span [] [ text "Post Now" ] ]
    ]


canceledActions : Tweet -> List (Html msg)
canceledActions tweet =
    [ div [ class "card-footer-item" ]
        [ span [] [ text "Canceled. " ]
        , a [] [ text "Undo?" ]
        ]
    ]


postedActions : Tweet -> List (Html msg)
postedActions tweet =
    [ div [ class "card-footer-item" ]
        [ icon Solid "check-circle"
        , span [] [ text "Posted. " ]
        , a [] [ text "View on Twitter" ]
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


tweetUserInfo : User -> Post -> Html Message
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
