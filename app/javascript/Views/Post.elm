module Views.Post exposing (..)

import Data.Post exposing (Post)
import Data.Tweet exposing (Tweet, Status(..))
import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Encode


type alias PostActions msg =
    { cancelTweet : Tweet -> msg }


postList : PostActions msg -> Maybe User -> List Post -> Html msg
postList actions user posts =
    div []
        [ div [ class "columns" ]
            [ div [ class "column has-text-centered" ]
                [ h2 [ class "title is-size-4" ] [ text "Posts" ]
                , hr [] []
                ]
            , div [ class "column has-text-centered" ]
                [ h2 [ class "title is-size-4" ] [ text "Tweets" ]
                , hr [] []
                ]
            ]
        , List.map (postEntry actions user) posts
            |> div []
        ]


postEntry : PostActions msg -> Maybe User -> Post -> Html msg
postEntry actions user post =
    div []
        [ div [ class "columns" ]
            [ div [ class "column" ]
                [ postTitle post
                , postContent post
                ]
            , div [ class "column" ] [ postTweets actions user post ]
            ]
        , hr [] []
        ]


postTitle : Post -> Html msg
postTitle post =
    if String.isEmpty post.title then
        h2 [ class "subtitle" ] [ text post.title ]
    else
        text ""


postContent : Post -> Html msg
postContent post =
    if String.isEmpty post.contentHtml then
        article [] [ text post.contentText ]
    else
        article
            [ class "content"
            , property "innerHTML" (Json.Encode.string post.contentHtml)
            ]
            []


postTweets : PostActions msg -> Maybe User -> Post -> Html msg
postTweets actions user post =
    div [] <| List.map (tweetCard actions user) post.tweets


tweetCard : PostActions msg -> Maybe User -> Tweet -> Html msg
tweetCard actions user tweet =
    article [ class "card" ]
        [ div [ class "card-content" ]
            [ tweetUserInfo user
            , p [] [ text tweet.body ]
            ]
        , footer [ class "card-footer" ] <|
            case tweet.status of
                Canceled ->
                    canceledActions tweet

                _ ->
                    draftActions actions tweet
        ]


draftActions : PostActions msg -> Tweet -> List (Html msg)
draftActions actions tweet =
    [ a
        [ href "#"
        , onClick <| actions.cancelTweet tweet
        , class "card-footer-item has-background-danger has-text-white"
        ]
        [ span [ class "icon" ] [ i [ class "fas fa-ban" ] [] ]
        , span [] [ text "Don't Post" ]
        ]
    , a [ href "#", class "card-footer-item has-background-primary has-text-white" ]
        [ span [ class "icon" ] [ i [ class "fas fa-pencil-alt" ] [] ]
        , span [] [ text "Edit Tweet" ]
        ]
    , a [ href "#", class "card-footer-item has-background-link has-text-white" ]
        [ span [ class "icon" ] [ i [ class "fas fa-share" ] [] ]
        , span [] [ text "Post Now" ]
        ]
    ]


canceledActions : Tweet -> List (Html msg)
canceledActions tweet =
    [ div [ class "card-footer-item" ]
        [ span [] [ text "Canceled. " ]
        , a [] [ text "Undo?" ]
        ]
    ]


tweetUserInfo : Maybe User -> Html msg
tweetUserInfo user =
    case user of
        Just user ->
            header [ class "media" ]
                [ div [ class "media-content" ]
                    [ h1 [ class "title is-5" ] [ text user.name ]
                    , h2 [ class "subtitle is-6 has-text-grey" ] [ text <| "@" ++ user.username ]
                    ]
                ]

        Nothing ->
            text ""
