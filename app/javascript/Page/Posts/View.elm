module Page.Posts.View exposing (view)

import Data.PostTweet exposing (PostTweet)
import Data.Tweet exposing (Tweet, Status(..))
import Data.User as User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Page.Posts.Model exposing (Model)
import Page.Posts.Update exposing (Message(..))
import Views.Icon exposing (..)
import Views.Page as Page
import Util.Editable exposing (Editable(..))


view : Model -> Html Message
view model =
    [ Page.navbar (Just model.user)
    , pageContent model
    , Page.footer
    ]
        |> div []


pageContent : Model -> Html Message
pageContent model =
    section [ class "section" ]
        [ div [ class "container" ]
            [ postList model.user model.tweets ]
        ]


postList : User -> List (Editable PostTweet) -> Html Message
postList user tweets =
    div []
        [ h2 [ class "title has-text-centered" ] [ text "Your Tweets" ]
        , hr [] []
        , List.map (postEntry user) tweets |> div []
        ]


postEntry : User -> Editable PostTweet -> Html Message
postEntry user tweet =
    div []
        [ div [ class "columns" ]
            [ div [ class "column is-two-thirds is-offset-2" ]
                [ tweetCard user tweet ]
            ]
        ]


tweetCard : User -> Editable PostTweet -> Html Message
tweetCard user postTweet =
    case postTweet of
        Viewing tweet ->
            viewTweetCard user tweet

        Editing _ tweet ->
            editTweetCard user tweet


viewTweetCard : User -> PostTweet -> Html Message
viewTweetCard user tweet =
    article [ class "card" ]
        [ div [ class "card-content" ]
            [ tweetUserInfo user
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
                [ tweetUserInfo user
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
        , onClick (SaveTweet tweet)
        ]
        [ span [] [ text "Save Draft" ] ]
    , a
        [ class "card-footer-item"
        , onClick (SaveTweet tweet)
        ]
        [ span [] [ text "Post Now " ] ]
    ]


tweetUserInfo : User -> Html msg
tweetUserInfo user =
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
