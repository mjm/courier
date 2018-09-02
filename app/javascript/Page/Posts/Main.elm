module Page.Posts.Main exposing (main)

import ActionCable
import Data.Post as Post
import Data.PostTweet as PostTweet exposing (PostTweet)
import Data.User as User exposing (User)
import Date
import Html
import Json.Decode exposing (decodeValue)
import Page.Posts.Flags exposing (Flags)
import Page.Posts.Model as Model exposing (Model, Message(..))
import Page.Posts.Update exposing (update)
import Page.Posts.View exposing (view)
import Task
import Time
import Unwrap
import Util.Editable exposing (Editable(..))


init : Flags -> ( Model, Cmd Message )
init flags =
    { tweets = tweetsFromFlags flags
    , user = userFromFlags flags
    , errors = []
    , now = Date.fromTime 0
    , cable =
        ActionCable.initCable flags.cableUrl
            |> ActionCable.onWelcome (Just Subscribe)
            |> ActionCable.onDidReceiveData (Just HandleSocketData)
    }
        ! [ Task.perform Tick Time.now ]


tweetsFromFlags : Flags -> List (Editable PostTweet)
tweetsFromFlags flags =
    decodeValue Post.listDecoder flags.posts
        |> Unwrap.result
        |> List.concatMap (PostTweet.fromPost)
        |> List.map Viewing


userFromFlags : Flags -> User
userFromFlags flags =
    decodeValue User.decoder flags.user
        |> Unwrap.result


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.batch
        [ Time.every (10 * Time.second) Tick
        , ActionCable.listen CableMsg model.cable
        ]


main : Program Flags Model Message
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
