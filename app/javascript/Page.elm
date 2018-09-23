module Page exposing (..)

import ActionCable exposing (ActionCable)
import ActionCable.Identifier as ID
import ActionCable.Msg as ACMsg
import Data.Event as Event exposing (Event)
import Data.User as User exposing (User)
import Date exposing (Date)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Task exposing (Task)
import Time exposing (Time)
import Unwrap
import Views.Error as Error
import Views.Icon exposing (..)


type alias Page msg =
    { now : Date
    , user : User
    , navbar : NavBar
    , modal : Maybe (Modal msg)
    , errors : List String
    , cable : ActionCable Message
    , wrapper : Message -> msg
    , onEvent : Event -> msg
    }


type alias NavBar =
    { isMenuOpen : Bool
    }


type alias Modal msg =
    { title : String
    , body : String
    , confirmText : String
    , confirmMsg : msg
    }


addError : Page msg -> String -> Page msg
addError page err =
    { page | errors = (err :: page.errors) }


removeError : Page msg -> String -> Page msg
removeError page err =
    let
        errors =
            List.filter (\e -> not (e == err)) page.errors
    in
        { page | errors = errors }


showModal : Page msg -> Modal msg -> Page msg
showModal page modal =
    { page | modal = Just modal }


dismissModal : Page msg -> Page msg
dismissModal page =
    { page | modal = Nothing }


dismissModalMsg : (Message -> msg) -> msg
dismissModalMsg wrapper =
    wrapper DismissModal


updateUser : Page msg -> User -> Page msg
updateUser page user =
    { page | user = user }


type Message
    = Tick Time
    | SetNavBarMenuOpen Bool
    | DismissError String
    | DismissModal
    | CableMsg ACMsg.Msg
    | Subscribe ()
    | HandleSocketData ID.Identifier Decode.Value


type alias Flags a =
    { a | user : Decode.Value, cableUrl : String }


init : Flags a -> (Message -> msg) -> (Event -> msg) -> Page msg
init flags wrapper onEvent =
    let
        user =
            Decode.decodeValue User.decoder flags.user |> Unwrap.result
    in
        { now = Date.fromTime 0
        , user = user
        , navbar = { isMenuOpen = False }
        , modal = Nothing
        , errors = []
        , cable =
            ActionCable.initCable flags.cableUrl
                |> ActionCable.onWelcome (Just Subscribe)
                |> ActionCable.onDidReceiveData (Just HandleSocketData)
        , wrapper = wrapper
        , onEvent = onEvent
        }


initTask : Task x Message
initTask =
    Task.map Tick Time.now


update : Message -> Page msg -> ( Page msg, Cmd msg )
update msg page =
    case msg of
        Tick time ->
            ( { page | now = Date.fromTime time }, Cmd.none )

        SetNavBarMenuOpen isOpen ->
            ( { page | navbar = setMenuOpen page.navbar isOpen }, Cmd.none )

        DismissError error ->
            ( { page | errors = List.filter (\e -> not (e == error)) page.errors }, Cmd.none )

        DismissModal ->
            ( dismissModal page, Cmd.none )

        CableMsg msg ->
            handleCableMessage msg page

        Subscribe () ->
            subscribe page

        HandleSocketData id value ->
            handleSocketData id value page


setMenuOpen : NavBar -> Bool -> NavBar
setMenuOpen navbar isOpen =
    { navbar | isMenuOpen = isOpen }


handleCableMessage : ACMsg.Msg -> Page msg -> ( Page msg, Cmd msg )
handleCableMessage msg model =
    ActionCable.update msg model.cable
        |> (\( cable, cmd ) ->
                { model | cable = cable } ! [ Cmd.map model.wrapper cmd ]
           )


subscribe : Page msg -> ( Page msg, Cmd msg )
subscribe model =
    case ActionCable.subscribeTo (ID.newIdentifier "EventsChannel" []) model.cable of
        Ok ( cable, cmd ) ->
            ( { model | cable = cable }
            , Cmd.map model.wrapper cmd
            )

        Err err ->
            ( model, Cmd.none )


handleSocketData : ID.Identifier -> Decode.Value -> Page msg -> ( Page msg, Cmd msg )
handleSocketData id value model =
    case Decode.decodeValue Event.decoder value of
        Ok event ->
            ( model, Task.perform identity (Task.succeed (model.onEvent event)) )

        Err _ ->
            ( model, Cmd.none )


subscriptions : Page msg -> Sub msg
subscriptions page =
    Sub.batch
        [ Time.every Time.second (\x -> page.wrapper (Tick x))
        , Sub.map page.wrapper (ActionCable.listen CableMsg page.cable)
        ]


view : Page msg -> Html msg -> Html msg
view page innerHtml =
    div []
        [ modal page.modal (page.wrapper DismissModal)
        , navbar page
        , Error.errors (\x -> page.wrapper (DismissError x)) page.errors
        , section [ class "section" ]
            [ div [ class "container" ]
                [ innerHtml ]
            ]
        , footer [ class "footer" ]
            [ div [ class "content has-text-centered" ]
                [ strong [] [ text "Courier" ]
                , text " is created by "
                , a [ href "https://mattmoriarity.com/" ] [ text "Matt Moriarity" ]
                , text "."
                ]
            ]
        ]


modal : Maybe (Modal msg) -> msg -> Html msg
modal modal dismiss =
    case modal of
        Just modal ->
            div [ class "modal is-active" ]
                [ div [ class "modal-background" ] []
                , div [ class "modal-card" ]
                    [ header [ class "modal-card-head" ]
                        [ p [ class "modal-card-title is-size-5" ]
                            [ text modal.title ]
                        , button
                            [ class "delete"
                            , onClick dismiss
                            ]
                            []
                        ]
                    , section [ class "modal-card-body" ]
                        [ p [] [ text modal.body ] ]
                    , footer [ class "modal-card-foot" ]
                        [ button
                            [ class "button is-danger"
                            , onClick modal.confirmMsg
                            ]
                            [ text modal.confirmText ]
                        ]
                    ]
                ]

        Nothing ->
            text ""


navbar : Page msg -> Html msg
navbar page =
    nav [ class "navbar is-info" ]
        [ navbarBrand page
        , navbarMenu page
        ]


navbarBrand : Page msg -> Html msg
navbarBrand page =
    div [ class "navbar-brand" ]
        [ a
            [ class "navbar-item has-text-weight-bold is-size-5"
            , href "/"
            ]
            [ span [ class "icon is-medium" ]
                [ i [ class "fas fa-paper-plane" ] [] ]
            , span [] [ text "Courier" ]
            ]
        , a
            [ class "navbar-burger has-text-white"
            , onClick (page.wrapper (SetNavBarMenuOpen (not page.navbar.isMenuOpen)))
            ]
            [ span [] []
            , span [] []
            , span [] []
            ]
        ]


navbarMenu : Page msg -> Html msg
navbarMenu page =
    div
        [ class "navbar-menu"
        , classList [ ( "is-active", page.navbar.isMenuOpen ) ]
        ]
        [ div [ class "navbar-end" ]
            [ profileNavbarItem page ]
        ]


profileNavbarItem : Page msg -> Html msg
profileNavbarItem page =
    div [ class "navbar-item has-dropdown is-hoverable" ]
        [ a [ class "navbar-link" ]
            [ icon Brand "twitter"
            , span [ class "has-text-weight-semibold" ]
                [ text page.user.name ]
            ]
        , div [ class "navbar-dropdown" ]
            [ a
                [ class "navbar-item"
                , href "/feeds"
                ]
                [ icon Solid "rss"
                , span [] [ text "Your Feeds" ]
                ]
            , a
                [ class "navbar-item"
                , href "/account"
                ]
                [ icon Solid "user-circle"
                , span [] [ text "Your Account" ]
                ]
            , hr [ class "navbar-divider" ] []
            , a
                [ class "navbar-item"
                , href "/sign_out"
                ]
                [ icon Solid "sign-out-alt"
                , span [] [ text "Sign Out" ]
                ]
            ]
        ]
