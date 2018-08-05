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
    div []
        [ navbar model
        , pageContent model
        ]


navbar : Model -> Html Message
navbar model =
    nav [ class "navbar is-info" ]
        [ navbarBrand
        , navbarMenu model
        ]


navbarBrand : Html Message
navbarBrand =
    div [ class "navbar-brand" ]
        [ a [ class "navbar-item has-text-weight-bold is-size-5" ]
            [ span [ class "icon is-medium" ]
                [ i [ class "fas fa-paper-plane" ] [] ]
            , span [] [ text "Courier" ]
            ]
        ]


navbarMenu : Model -> Html Message
navbarMenu model =
    div [ class "navbar-menu" ]
        [ div [ class "navbar-end" ]
            [ div [ class "navbar-item" ]
                [ case model.user of
                    Just user ->
                        span []
                            [ span [ class "icon" ]
                                [ i [ class "fab fa-twitter" ] [] ]
                            , span [ class "has-text-weight-semibold" ]
                                [ text user.name ]
                            ]

                    Nothing ->
                        text ""
                ]
            ]
        ]


pageContent : Model -> Html Message
pageContent model =
    section [ class "section" ]
        [ div [ class "container" ]
            [ postList model.posts ]
        ]


welcomeMessage : Maybe User -> Html Message
welcomeMessage user =
    case user of
        Just user ->
            p [] [ text ("Welcome, " ++ user.name) ]

        Nothing ->
            text ""


postList : List Post -> Html Message
postList posts =
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
        , List.map postEntry posts
            |> div []
        ]


postEntry : Post -> Html Message
postEntry post =
    div []
        [ div [ class "columns" ]
            [ div [ class "column" ]
                [ postTitle post
                , postContent post
                ]
            , div [ class "column" ] [ postTweets post ]
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


postTweets : Post -> Html Message
postTweets post =
    div [] <| List.map postTweet post.tweets


postTweet : Tweet -> Html Message
postTweet tweet =
    article [ class "card is-primary" ]
        [ div [ class "card-content" ]
            [ text tweet.body ]
        ]



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
