module Main exposing (..)

import Data.Post as Post exposing (Post)
import Data.Tweet as Tweet exposing (Tweet)
import Data.User as User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Request.Post
import Request.User
import Views.Page as Page
import Views.Post exposing (PostActions, postList)


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


postActions : PostActions Message
postActions =
    { cancelTweet = CancelTweet }


pageContent : Model -> Html Message
pageContent model =
    section [ class "section" ]
        [ div [ class "container" ]
            [ postList postActions model.user model.posts ]
        ]



-- MESSAGE


type Message
    = UserInfoResp (Result Http.Error User)
    | PostsLoaded (Result Http.Error (List Post))
    | CancelTweet Tweet
    | CanceledTweet (Result Http.Error Tweet)



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

        CancelTweet tweet ->
            ( model, Http.send CanceledTweet <| Request.Post.cancelTweet tweet )

        CanceledTweet (Ok tweet) ->
            ( updateTweet tweet model, Cmd.none )

        CanceledTweet (Err _) ->
            ( model, Cmd.none )


updateTweet : Tweet -> Model -> Model
updateTweet tweet model =
    let
        posts =
            List.map (updatePostTweet tweet)
                model.posts
    in
        { model | posts = posts }


updatePostTweet : Tweet -> Post -> Post
updatePostTweet tweet post =
    let
        tweets =
            List.map
                (\postTweet ->
                    if tweet.id == postTweet.id then
                        tweet
                    else
                        postTweet
                )
                post.tweets
    in
        { post | tweets = tweets }



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
