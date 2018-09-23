module Page.Helper exposing (..)

import Page exposing (Page)


type alias PageModel a msg =
    { a | page : Page msg }


addError : PageModel a msg -> String -> PageModel a msg
addError model err =
    { model | page = Page.addError model.page err }


showModal : PageModel a msg -> Page.Modal msg -> PageModel a msg
showModal model modal =
    { model | page = Page.showModal model.page modal }


dismissModal : PageModel a msg -> PageModel a msg
dismissModal model =
    { model | page = Page.dismissModal model.page }
