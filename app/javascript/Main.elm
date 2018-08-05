module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Json.Encode as Encode


-- MODEL


type alias Model =
    { text : String
    , tweetText : String
    }



-- INIT


init : ( Model, Cmd Message )
init =
    ( Model "" "", Cmd.none )



-- VIEW


view : Model -> Html Message
view model =
    div []
        [ h1 [] [ text "Welcome to Courier" ]
        , Html.form [ onSubmit Translate ]
            [ textarea
                [ placeholder "Text to translate"
                , value model.text
                , onInput SetText
                ]
                []
            , button [] [ text "Translate" ]
            , pre [] [ text model.tweetText ]
            ]
        ]



-- MESSAGE


type Message
    = None
    | SetText String
    | Translate
    | TranslateResp (Result Http.Error String)



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        None ->
            ( model, Cmd.none )

        SetText text ->
            ( { model | text = text }, Cmd.none )

        Translate ->
            ( model, translateText model.text )

        TranslateResp (Ok tweetText) ->
            ( { model | tweetText = tweetText }, Cmd.none )

        TranslateResp (Err _) ->
            ( model, Cmd.none )



-- HTTP


translateText : String -> Cmd Message
translateText text =
    let
        request =
            callApi "Translate" (encodeTweetText text) decodeTranslatedTweet
    in
        Http.send TranslateResp request


callApi : String -> Encode.Value -> Decode.Decoder a -> Http.Request a
callApi method bodyValue =
    Http.post ("/courier.Api/" ++ method) (Http.jsonBody bodyValue)


encodeTweetText : String -> Encode.Value
encodeTweetText text =
    Encode.object [ ( "content_html", Encode.string text ) ]


decodeTranslatedTweet : Decode.Decoder String
decodeTranslatedTweet =
    Decode.field "body" Decode.string



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
