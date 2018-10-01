module Page exposing (Flags, Message(..), Modal, NavBar, Page, addError, dismissModal, init, initTask, modalInProgress, removeError, showModal, subscriptions, update, updateUser, view)

import Data.Event as Event exposing (Event)
import Data.User as User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Decode as Decode
import Task exposing (Task)
import Time exposing (Posix)
import Views.Error as Error
import Views.Icon exposing (..)


type alias Page msg =
    { now : Posix
    , user : User
    , navbar : NavBar
    , modal : ModalState msg
    , errors : List String
    , wrapper : Message -> msg
    }


type alias NavBar =
    { isMenuOpen : Bool
    }


type ModalState msg
    = Dismissed
    | Showing (Modal msg)
    | InProgress (Modal msg)


type alias Modal msg =
    { title : String
    , body : String
    , confirmText : String
    , confirmMsg : msg
    }


addError : Page msg -> String -> Page msg
addError page err =
    { page | errors = err :: page.errors }


removeError : Page msg -> String -> Page msg
removeError page err =
    let
        errors =
            List.filter (\e -> not (e == err)) page.errors
    in
    { page | errors = errors }


showModal : Page msg -> Modal msg -> Page msg
showModal page modal =
    { page | modal = Showing modal }


modalInProgress : Page msg -> Page msg
modalInProgress page =
    let
        modalState =
            case page.modal of
                Showing m ->
                    InProgress m

                _ ->
                    page.modal
    in
    { page | modal = modalState }


dismissModal : Page msg -> Page msg
dismissModal page =
    { page | modal = Dismissed }


updateUser : Page msg -> User -> Page msg
updateUser page user =
    { page | user = user }


type Message
    = Tick Posix
    | SetNavBarMenuOpen Bool
    | DismissError String
    | DismissModal


type alias Flags a =
    { a | user : Decode.Value }


init : Flags a -> (Message -> msg) -> Page msg
init flags wrapper =
    let
        user =
            case Decode.decodeValue User.decoder flags.user of
                Ok x ->
                    x

                Err _ ->
                    User.empty
    in
    { now = Time.millisToPosix 0
    , user = user
    , navbar = { isMenuOpen = False }
    , modal = Dismissed
    , errors = []
    , wrapper = wrapper
    }


initTask : Task x Message
initTask =
    Task.map Tick Time.now


update : Message -> Page msg -> ( Page msg, Cmd msg )
update msg page =
    case msg of
        Tick time ->
            ( { page | now = time }, Cmd.none )

        SetNavBarMenuOpen isOpen ->
            ( { page | navbar = setMenuOpen page.navbar isOpen }, Cmd.none )

        DismissError error ->
            ( { page | errors = List.filter (\e -> not (e == error)) page.errors }, Cmd.none )

        DismissModal ->
            ( dismissModal page, Cmd.none )


setMenuOpen : NavBar -> Bool -> NavBar
setMenuOpen navbar isOpen =
    { navbar | isMenuOpen = isOpen }


subscriptions : Page msg -> Sub msg
subscriptions page =
    Sub.batch
        [ Time.every 1000 (\x -> page.wrapper (Tick x))
        ]


view : Page msg -> Html msg -> Html msg
view page innerHtml =
    div []
        [ modalView page.modal (page.wrapper DismissModal)
        , navbarView page
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


modalView : ModalState msg -> msg -> Html msg
modalView state dismiss =
    case state of
        Showing m ->
            showingModal m dismiss

        InProgress m ->
            inProgressModal m

        Dismissed ->
            text ""


showingModal : Modal msg -> msg -> Html msg
showingModal modal dismiss =
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
                    [ icon Solid "check"
                    , span [] [ text modal.confirmText ]
                    ]
                ]
            ]
        ]


inProgressModal : Modal msg -> Html msg
inProgressModal modal =
    div [ class "modal is-active" ]
        [ div [ class "modal-background" ] []
        , div [ class "modal-card" ]
            [ header [ class "modal-card-head" ]
                [ p [ class "modal-card-title is-size-5" ]
                    [ text modal.title ]
                , button
                    [ class "delete"
                    ]
                    []
                ]
            , section [ class "modal-card-body" ]
                [ p [] [ text modal.body ] ]
            , footer [ class "modal-card-foot" ]
                [ button
                    [ class "button is-danger"
                    , disabled True
                    ]
                    [ icon Solid "spinner fa-spin"
                    , span [] [ text modal.confirmText ]
                    ]
                ]
            ]
        ]


navbarView : Page msg -> Html msg
navbarView page =
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
