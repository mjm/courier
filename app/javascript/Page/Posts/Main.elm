module Page.Posts.Main exposing (main)

import Html
import Http
import Page.Posts.Model as Model exposing (Model)
import Page.Posts.Update exposing (Message(..), update)
import Page.Posts.View exposing (view)
import Request.Post
import Request.User


init : ( Model, Cmd Message )
init =
    Model.initial
        ! [ Http.send UserLoaded Request.User.getUserInfo
          , Http.send PostsLoaded Request.Post.posts
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