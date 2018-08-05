module Main exposing (..)

import Data.Post as Post exposing (Post)
import Data.Tweet as Tweet exposing (Tweet)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Json.Encode as Encode


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
    = None
    | SetPostHtml String
    | Translate
    | TranslateResp (Result Http.Error Tweet)



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        None ->
            ( model, Cmd.none )

        SetPostHtml text ->
            let
                currentPost =
                    model.post
            in
                ( { model | post = { currentPost | contentHtml = text } }, Cmd.none )

        Translate ->
            ( model, translatePost model.post )

        TranslateResp (Ok tweet) ->
            ( { model | tweet = tweet }, Cmd.none )

        TranslateResp (Err _) ->
            ( model, Cmd.none )



-- HTTP


translatePost : Post -> Cmd Message
translatePost post =
    let
        request =
            callApi "Translate" (Post.encode post) Tweet.decoder
    in
        Http.send TranslateResp request


callApi : String -> Encode.Value -> Decode.Decoder a -> Http.Request a
callApi method bodyValue =
    Http.post ("/courier.Api/" ++ method) (Http.jsonBody bodyValue)



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
