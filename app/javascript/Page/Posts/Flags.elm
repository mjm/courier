module Page.Posts.Flags exposing (Flags)

import Json.Decode


type alias Flags =
    { tweets : Json.Decode.Value
    , user : Json.Decode.Value
    , cableUrl : String
    }
