module Page.Account.Model exposing (Model, Message(..))

import Data.User exposing (User)
import Date exposing (Date)
import Time exposing (Time)


type alias Model =
    { user : User
    , stripeKey : String
    , now : Date
    }


type Message
    = Tick Time
