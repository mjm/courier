module Page.Account.Model exposing (Model, Message(..))

import Data.User exposing (User)


type alias Model =
    { user : User
    , stripeKey : String
    }


type Message
    = NoOp
