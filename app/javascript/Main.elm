module Main exposing (..)

import Data.Post as Post exposing (Post)
import Data.Tweet as Tweet exposing (Tweet)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Request.Translate


-- MODEL


type alias Model =
    { post : Post
    , tweet : Tweet
    }



-- INIT


init : ( Model, Cmd Message )
init =
    ( Model
        (Post "")
        (Tweet "")
    , Cmd.none
    )



-- VIEW


view : Model -> Html Message
view model =
    div []
        [ h1 [] [ text "Welcome to Courier" ]
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



-- MESSAGE


type Message
    = SetPostHtml String
    | Translate
    | TranslateResp (Result Http.Error Tweet)



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
