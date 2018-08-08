module Page.Feeds exposing (main)

import Data.Feed exposing (Feed, DraftFeed)
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
import Views.Error as Error
import Views.Icon exposing (..)
import Views.Page as Page


-- MODEL


type alias Model =
    { user : Maybe User
    , feeds : List Feed
    , draftFeed : Maybe DraftFeed
    , errors : List String
    }



-- INIT


init : ( Model, Cmd Message )
init =
    initialModel ! [ loadUserInfo, loadFeeds ]


initialModel : Model
initialModel =
    { user = Nothing
    , feeds = []
    , draftFeed = Nothing
    , errors = []
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
    , Error.errors DismissError model.errors
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
    case model.draftFeed of
        Just feed ->
            addFeedForm feed

        Nothing ->
            addFeedButton


addFeedButton : Html Message
addFeedButton =
    p [ class "has-text-centered" ]
        [ button
            [ class "button is-rounded is-primary is-large"
            , onClick (SetAddingFeed True)
            ]
            [ icon Solid "plus-circle"
            , span [] [ text "Add Feed" ]
            ]
        ]


addFeedForm : DraftFeed -> Html Message
addFeedForm feed =
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
    | DismissError String
    | UserInfoLoaded (Result Http.Error User)
    | FeedsLoaded (Result Http.Error (List Feed))
    | SetAddingFeed Bool
    | SetDraftFeedUrl String
    | AddFeed
    | FeedAdded (Result Http.Error Feed)



-- UPDATE


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        Noop ->
            ( model, Cmd.none )

        DismissError err ->
            ( removeError model err, Cmd.none )

        UserInfoLoaded (Ok user) ->
            ( { model | user = Just user }, Cmd.none )

        UserInfoLoaded (Err _) ->
            ( addError model "Could not your user profile. Please try again later.", Cmd.none )

        FeedsLoaded (Ok feeds) ->
            ( { model | feeds = feeds }, Cmd.none )

        FeedsLoaded (Err _) ->
            ( addError model "Could not load your feeds right now. Please try again later.", Cmd.none )

        SetAddingFeed isAdding ->
            if isAdding then
                ( { model | draftFeed = Just (DraftFeed "") }
                , Task.attempt (\_ -> Noop) (Dom.focus "add-feed-url")
                )
            else
                ( { model | draftFeed = Nothing }, Cmd.none )

        SetDraftFeedUrl url ->
            ( { model | draftFeed = updateFeedUrl model.draftFeed url }, Cmd.none )

        AddFeed ->
            case model.draftFeed of
                Just feed ->
                    ( { model | draftFeed = Nothing }
                    , Http.send FeedAdded (Request.Feed.register feed)
                    )

                Nothing ->
                    ( model, Cmd.none )

        FeedAdded (Ok feed) ->
            let
                feeds =
                    model.feeds ++ [ feed ]
            in
                ( { model | feeds = feeds }, Cmd.none )

        FeedAdded (Err _) ->
            ( addError model "Could not add the feed right now. Please try again later.", Cmd.none )


updateFeedUrl : Maybe DraftFeed -> String -> Maybe DraftFeed
updateFeedUrl feed url =
    case feed of
        Just draftFeed ->
            Just { draftFeed | url = url }

        Nothing ->
            Just (DraftFeed url)


addError : Model -> String -> Model
addError model err =
    let
        errors =
            err :: model.errors
    in
        { model | errors = errors }


removeError : Model -> String -> Model
removeError model err =
    let
        errors =
            List.filter (\e -> not (e == err)) model.errors
    in
        { model | errors = errors }



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
