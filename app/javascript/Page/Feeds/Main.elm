module Page.Feeds.Main exposing (main)

import Html
import Http
import Page.Feeds.Model as Model exposing (Model)
import Page.Feeds.Update exposing (Message(..), update)
import Page.Feeds.View exposing (view)
import Request.User
import Request.Feed


init : ( Model, Cmd Message )
init =
    Model.initial
        ! [ Http.send UserLoaded Request.User.getUserInfo
          , Http.send FeedsLoaded Request.Feed.feeds
          ]


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.none


main : Program Never Model Message
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
