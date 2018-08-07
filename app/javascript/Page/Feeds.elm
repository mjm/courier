module Page.Feeds exposing (main)

import Data.Feed exposing (Feed)
import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Request.User
import Views.Page as Page


-- MODEL


type alias Model =
    { user : Maybe User
    , feeds : List Feed
    }



-- INIT


init : ( Model, Cmd Message )
init =
    initialModel ! [ loadUserInfo ]


initialModel : Model
initialModel =
    { user = Nothing
    , feeds = [ Feed 1 "https://example.com/feed.json" ]
    }


loadUserInfo : Cmd Message
loadUserInfo =
    Http.send UserInfoLoaded Request.User.getUserInfo



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
            [ h1 [ class "title has-text-centered" ] [ text "Your Feeds" ]
            , hr [] []
            , feeds model.feeds
            ]
        ]


feeds : List Feed -> Html Message
feeds fs =
    case fs of
        [] ->
            p [ class "has-text-centered" ]
                [ text "You don't have any feeds registered." ]

        fs ->
            List.map feedRow fs
                |> ul []


feedRow : Feed -> Html Message
feedRow feed =
    li [] [ text feed.url ]



-- MESSAGE


type Message
    = UserInfoLoaded (Result Http.Error User)



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        UserInfoLoaded (Ok user) ->
            ( { model | user = Just user }, Cmd.none )

        UserInfoLoaded (Err _) ->
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
