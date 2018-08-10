module Views.Post exposing (..)

import Data.Post exposing (Post)
import Data.Tweet exposing (Tweet, Status(..))
import Data.User as User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Encode
import Views.Icon exposing (..)
import Util exposing (Loadable(..))


type alias PostActions msg =
    { cancelTweet : Tweet -> msg }


postList : PostActions msg -> Maybe User -> Loadable (List Post) -> Html msg
postList actions user posts =
    div []
        [ h2 [ class "title has-text-centered" ] [ text "Your Tweets" ]
        , hr [] []
        , case posts of
            Loading ->
                loadingPosts

            Loaded posts ->
                List.map (postEntry actions user) posts |> div []
        ]


loadingPosts : Html msg
loadingPosts =
    p [ class "has-text-centered is-size-5" ]
        [ span [ class "rotating icon is-medium" ] [ i [ class "fas fa-spinner" ] [] ]
        , span [] [ text "Loading posts..." ]
        , p [] [ text " " ]
        ]


postEntry : PostActions msg -> Maybe User -> Post -> Html msg
postEntry actions user post =
    div []
        [ div [ class "columns" ]
            [ div [ class "column is-two-thirds is-offset-2" ]
                [ postTweets actions user post ]
            ]
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
                Draft ->
                    draftActions actions tweet

                Canceled ->
                    canceledActions tweet

                Posted ->
                    postedActions tweet
        ]


draftActions : PostActions msg -> Tweet -> List (Html msg)
draftActions actions tweet =
    [ a
        [ onClick <| actions.cancelTweet tweet
        , class "card-footer-item has-text-danger"
        ]
        [ icon Solid "ban", span [] [ text "Don't Post" ] ]
    , a
        [ class "card-footer-item has-text-primary" ]
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


tweetUserInfo : Maybe User -> Html msg
tweetUserInfo user =
    case user of
        Just user ->
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

        Nothing ->
            text ""
