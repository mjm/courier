module Page.Feeds.Flags exposing (Flags)

import Json.Decode


type alias Flags =
    { feeds : Json.Decode.Value
    , user : Json.Decode.Value
    , environment : String
    }
