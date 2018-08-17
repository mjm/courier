module Page.Posts.Main exposing (main)

import Data.Post as Post
import Data.PostTweet as PostTweet exposing (PostTweet)
import Data.User as User exposing (User)
import Date
import Html
import Json.Decode exposing (decodeValue)
import Page.Posts.Flags exposing (Flags)
import Page.Posts.Model as Model exposing (Model)
import Page.Posts.Update exposing (Message(..), update)
import Page.Posts.View exposing (view)
import Task
import Time
import Unwrap
import Util.Editable exposing (Editable(..))


init : Flags -> ( Model, Cmd Message )
init flags =
    { tweets = tweetsFromFlags flags
    , user = userFromFlags flags
    , now = Date.fromTime 0
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
    Time.every (10 * Time.second) Tick


main : Program Flags Model Message
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
