module Page.Posts.Model exposing (Model)

import Data.PostTweet exposing (PostTweet)
import Data.User exposing (User)
import Util.Editable exposing (Editable(..))
import Util.Loadable exposing (Loadable(..))


type alias Model =
    { tweets : Loadable (List (Editable PostTweet))
    , user : User
    }
