module Page.Posts.Flags exposing (Flags)

import Json.Decode


type alias Flags =
    { posts : Json.Decode.Value
    , user : Json.Decode.Value
    }
