module Page.Account.Flags exposing (Flags)

import Json.Decode


type alias Flags =
    { user : Json.Decode.Value
    , cableUrl : String
    , stripeKey : String
    }
