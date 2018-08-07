module Page.Feeds exposing (main)

import Data.Feed exposing (Feed)
import Data.User exposing (User)
import Dom
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Events.Extra exposing (onClickPreventDefault)
import Http
import Request.User
import Request.Feed
import Task
import Views.Page as Page


-- MODEL


type alias Model =
    { user : Maybe User
    , feeds : List Feed
    , isAddingFeed : Bool
    , draftFeedUrl : String
    }



-- INIT


init : ( Model, Cmd Message )
init =
    initialModel ! [ loadUserInfo, loadFeeds ]


initialModel : Model
initialModel =
    { user = Nothing
    , feeds = []
    , isAddingFeed = False
    , draftFeedUrl = ""
    }


loadUserInfo : Cmd Message
loadUserInfo =
    Http.send UserInfoLoaded Request.User.getUserInfo


loadFeeds : Cmd Message
loadFeeds =
    Http.send FeedsLoaded Request.Feed.feeds



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
            , div [ class "columns" ]
                [ div [ class "column is-8 is-offset-2" ]
                    [ feeds model.feeds
                    , p [] [ text " " ]
                    , addFeed model
                    ]
                ]
            ]
        ]


feeds : List Feed -> Html Message
feeds fs =
    case fs of
        [] ->
            p [ class "has-text-centered" ]
                [ text "You don't have any feeds registered." ]

        fs ->
            List.map feedRow fs |> ul []


feedRow : Feed -> Html Message
feedRow feed =
    li [ class "box" ]
        [ button [ class "delete is-pulled-right" ] []
        , span [ class "icon is-medium has-text-link" ]
            [ i [ class "fas fa-rss fa-lg" ] [] ]
        , span [ class "is-size-5" ] [ text feed.url ]
        ]


addFeed : Model -> Html Message
addFeed model =
    if model.isAddingFeed then
        addFeedForm
    else
        addFeedButton


addFeedButton : Html Message
addFeedButton =
    p [ class "has-text-centered" ]
        [ button
            [ class "button is-rounded is-primary is-large"
            , onClick (SetAddingFeed True)
            ]
            [ span [ class "icon" ] [ i [ class "fas fa-plus-circle" ] [] ]
            , span [] [ text "Add Feed" ]
            ]
        ]


addFeedForm : Html Message
addFeedForm =
    Html.form
        [ action "javascript:void(0);"
        , onSubmit AddFeed
        ]
        [ div [ class "field" ]
            [ div [ class "control" ]
                [ input
                    [ id "add-feed-url"
                    , type_ "text"
                    , class "input is-medium"
                    , placeholder "Feed URL"
                    , onInput SetDraftFeedUrl
                    ]
                    []
                ]
            ]
        , div [ class "field is-grouped is-grouped-right" ]
            [ p [ class "control" ]
                [ button
                    [ class "button is-light"
                    , onClickPreventDefault (SetAddingFeed False)
                    ]
                    [ text "Cancel" ]
                ]
            , p [ class "control" ]
                [ button [ class "button is-primary" ]
                    [ text "Add Feed" ]
                ]
            ]
        ]



-- MESSAGE


type Message
    = Noop
    | UserInfoLoaded (Result Http.Error User)
    | FeedsLoaded (Result Http.Error (List Feed))
    | SetAddingFeed Bool
    | SetDraftFeedUrl String
    | AddFeed



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        Noop ->
            ( model, Cmd.none )

        UserInfoLoaded (Ok user) ->
            ( { model | user = Just user }, Cmd.none )

        UserInfoLoaded (Err _) ->
            ( model, Cmd.none )

        FeedsLoaded (Ok feeds) ->
            ( { model | feeds = feeds }, Cmd.none )

        FeedsLoaded (Err _) ->
            ( model, Cmd.none )

        SetAddingFeed isAdding ->
            ( { model | isAddingFeed = isAdding }
            , if isAdding then
                Task.attempt (\_ -> Noop) (Dom.focus "add-feed-url")
              else
                Cmd.none
            )

        SetDraftFeedUrl url ->
            ( { model | draftFeedUrl = url }, Cmd.none )

        AddFeed ->
            let
                feeds =
                    model.feeds ++ [ Feed 123 model.draftFeedUrl ]
            in
                ( { model | feeds = feeds, isAddingFeed = False }, Cmd.none )



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
