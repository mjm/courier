module Main exposing (..)

import Data.Post as Post exposing (Post)
import Data.PostTweet as PostTweet exposing (PostTweet)
import Data.Tweet as Tweet exposing (Tweet)
import Data.User as User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Request.Post
import Request.User
import Views.Page as Page
import Views.Post exposing (PostActions, postList)
import Util.Editable as Editable exposing (Editable(..))
import Util.Loadable as Loadable exposing (Loadable(..))


-- MODEL


type alias Model =
    { tweets : Loadable (List (Editable PostTweet))
    , user : Maybe User
    }



-- INIT


init : ( Model, Cmd Message )
init =
    initialModel ! [ loadUserInfo, loadPosts ]


initialModel : Model
initialModel =
    { tweets = Loading
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
    { cancelTweet = CancelTweet
    , editTweet = EditTweet
    , setTweetBody = SetTweetBody
    , cancelEditTweet = CancelEditTweet
    , saveTweet = SaveTweet
    , saveAndPostTweet = SaveTweet
    }


pageContent : Model -> Html Message
pageContent model =
    section [ class "section" ]
        [ div [ class "container" ]
            [ postList postActions model.user model.tweets ]
        ]



-- MESSAGE


type Message
    = UserInfoResp (Result Http.Error User)
    | PostsLoaded (Result Http.Error (List Post))
    | CancelTweet Tweet
    | CanceledTweet (Result Http.Error Tweet)
    | EditTweet Tweet
    | SetTweetBody Tweet String
    | CancelEditTweet Tweet
    | SaveTweet Tweet



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        UserInfoResp (Ok user) ->
            ( { model | user = Just user }, Cmd.none )

        UserInfoResp (Err _) ->
            ( model, Cmd.none )

        PostsLoaded (Ok posts) ->
            ( { model | tweets = Loaded (tweetsFromPosts posts) }, Cmd.none )

        PostsLoaded (Err _) ->
            ( model, Cmd.none )

        CancelTweet tweet ->
            ( model, Http.send CanceledTweet <| Request.Post.cancelTweet tweet )

        CanceledTweet (Ok tweet) ->
            ( updateTweet tweet model, Cmd.none )

        CanceledTweet (Err _) ->
            ( model, Cmd.none )

        EditTweet tweet ->
            ( { model | tweets = Loadable.map (editTweet tweet) model.tweets }, Cmd.none )

        SetTweetBody tweet body ->
            let
                updater =
                    \x -> { x | body = body }
            in
                ( { model | tweets = Loadable.map (updateDraftTweet updater tweet) model.tweets }, Cmd.none )

        CancelEditTweet tweet ->
            ( { model | tweets = Loadable.map (cancelEditTweet tweet) model.tweets }, Cmd.none )

        SaveTweet tweet ->
            ( { model | tweets = Loadable.map (saveTweet tweet) model.tweets }, Cmd.none )


tweetsFromPosts : List Post -> List (Editable PostTweet)
tweetsFromPosts posts =
    List.concatMap (PostTweet.fromPost) posts
        |> List.map Viewing


updateTweet : Tweet -> Model -> Model
updateTweet tweet model =
    case model.tweets of
        Loading ->
            model

        Loaded tweets ->
            let
                updatedTweets =
                    List.map (updatePostTweet tweet) tweets
            in
                { model | tweets = Loaded updatedTweets }


updatePostTweet : Tweet -> Editable PostTweet -> Editable PostTweet
updatePostTweet tweet postTweet =
    case postTweet of
        Viewing t ->
            Viewing (PostTweet.updateTweet t tweet)

        Editing orig edit ->
            Editing (PostTweet.updateTweet orig tweet) edit


editTweet : Tweet -> List (Editable PostTweet) -> List (Editable PostTweet)
editTweet t =
    Editable.edit (\x -> x.tweet.id == t.id)


updateDraftTweet : (Tweet -> Tweet) -> Tweet -> List (Editable PostTweet) -> List (Editable PostTweet)
updateDraftTweet f t =
    Editable.updateDraft
        (\x -> x.tweet.id == t.id)
        (\x -> { x | tweet = f x.tweet })


cancelEditTweet : Tweet -> List (Editable PostTweet) -> List (Editable PostTweet)
cancelEditTweet t =
    Editable.cancel (\x -> x.tweet.id == t.id)


saveTweet : Tweet -> List (Editable PostTweet) -> List (Editable PostTweet)
saveTweet t =
    Editable.save
        (\x -> x.tweet.id == t.id)
        (\x -> { x | tweet = t })



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
