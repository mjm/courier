module Main exposing (..)

import Data.Post as Post exposing (Post)
import Data.Tweet as Tweet exposing (Tweet)
import Data.User as User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Request.User
import Request.Translate


-- MODEL


type alias Model =
    { post : Post
    , tweet : Tweet
    , user : Maybe User
    }



-- INIT


init : ( Model, Cmd Message )
init =
    ( initialModel, loadUserInfo )


initialModel : Model
initialModel =
    { post = Post ""
    , tweet = Tweet ""
    , user = Nothing
    }


loadUserInfo : Cmd Message
loadUserInfo =
    Http.send UserInfoResp Request.User.getUserInfo



-- VIEW


view : Model -> Html Message
view model =
    div []
        [ h1 [] [ text "Courier" ]
        , welcomeMessage model.user
        , Html.form [ onSubmit Translate ]
            [ textarea
                [ placeholder "HTML to translate"
                , value model.post.contentHtml
                , onInput SetPostHtml
                ]
                []
            , button [] [ text "Translate" ]
            , pre [] [ text model.tweet.body ]
            ]
        ]


welcomeMessage : Maybe User -> Html Message
welcomeMessage user =
    case user of
        Just user ->
            p [] [ text ("Welcome, " ++ user.name) ]

        Nothing ->
            text ""



-- MESSAGE


type Message
    = SetPostHtml String
    | Translate
    | TranslateResp (Result Http.Error Tweet)
    | UserInfoResp (Result Http.Error User)



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        SetPostHtml text ->
            let
                currentPost =
                    model.post
            in
                ( { model | post = { currentPost | contentHtml = text } }, Cmd.none )

        Translate ->
            ( model
            , Http.send TranslateResp (Request.Translate.translate model.post)
            )

        TranslateResp (Ok tweet) ->
            ( { model | tweet = tweet }, Cmd.none )

        TranslateResp (Err _) ->
            ( model, Cmd.none )

        UserInfoResp (Ok user) ->
            ( { model | user = Just user }, Cmd.none )

        UserInfoResp (Err _) ->
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
