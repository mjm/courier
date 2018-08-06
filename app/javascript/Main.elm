module Main exposing (..)

import Data.Post as Post exposing (Post)
import Data.Tweet as Tweet exposing (Tweet)
import Data.User as User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Encode
import Request.Post
import Request.User
import Views.Page as Page


-- MODEL


type alias Model =
    { posts : List Post
    , user : Maybe User
    }



-- INIT


init : ( Model, Cmd Message )
init =
    initialModel ! [ loadUserInfo, loadPosts ]


initialModel : Model
initialModel =
    { posts = []
    , user = Nothing
    }


loadUserInfo : Cmd Message
loadUserInfo =
    Http.send UserInfoResp Request.User.getUserInfo


loadPosts : Cmd Message
loadPosts =
    Http.send PostsLoaded Request.Post.posts



-- VIEW


view : Model -> Html Message
view model =
    [ Page.navbar model.user
    , pageContent model
    , Page.footer
    ]
        |> div []


pageContent : Model -> Html Message
pageContent model =
    section [ class "section" ]
        [ div [ class "container" ]
            [ postList model.user model.posts ]
        ]


postList : Maybe User -> List Post -> Html Message
postList user posts =
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
        , List.map (postEntry user) posts
            |> div []
        ]


postEntry : Maybe User -> Post -> Html Message
postEntry user post =
    div []
        [ div [ class "columns" ]
            [ div [ class "column" ]
                [ postTitle post
                , postContent post
                ]
            , div [ class "column" ] [ postTweets user post ]
            ]
        , hr [] []
        ]


postTitle : Post -> Html Message
postTitle post =
    if String.isEmpty post.title then
        h2 [ class "subtitle" ] [ text post.title ]
    else
        text ""


postContent : Post -> Html Message
postContent post =
    if String.isEmpty post.contentHtml then
        article [] [ text post.contentText ]
    else
        article
            [ class "content"
            , property "innerHTML" (Json.Encode.string post.contentHtml)
            ]
            []


postTweets : Maybe User -> Post -> Html Message
postTweets user post =
    div [] <| List.map (tweetCard user) post.tweets


tweetCard : Maybe User -> Tweet -> Html Message
tweetCard user tweet =
    article [ class "card" ]
        [ div [ class "card-content" ]
            [ tweetUserInfo user
            , p [] [ text tweet.body ]
            ]
        , footer [ class "card-footer" ]
            [ a [ href "#", class "card-footer-item has-background-danger has-text-white" ]
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



-- MESSAGE


type Message
    = UserInfoResp (Result Http.Error User)
    | PostsLoaded (Result Http.Error (List Post))



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        UserInfoResp (Ok user) ->
            ( { model | user = Just user }, Cmd.none )

        UserInfoResp (Err _) ->
            ( model, Cmd.none )

        PostsLoaded (Ok posts) ->
            ( { model | posts = posts }, Cmd.none )

        PostsLoaded (Err _) ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.none



-- MAIN


main : Program Never Model Message
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
