module Main exposing (..)

import Data.Post as Post exposing (Post)
import Data.User as User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Request.Post
import Request.User
import Views.Page as Page
import Views.Post exposing (postList)


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
