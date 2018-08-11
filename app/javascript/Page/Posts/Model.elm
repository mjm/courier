module Page.Posts.Model exposing (Model)

import Data.PostTweet exposing (PostTweet)
import Data.User exposing (User)
import Util.Editable exposing (Editable(..))


type alias Model =
    { tweets : List (Editable PostTweet)
    , user : User
    }
