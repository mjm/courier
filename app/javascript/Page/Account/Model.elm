module Page.Account.Model exposing (Model, Message(..))

import Data.User exposing (User)
import Date exposing (Date)
import Http
import Time exposing (Time)
import Views.Modal exposing (Modal)


type alias Model =
    { user : User
    , stripeKey : String
    , now : Date
    , modal : Maybe (Modal Message)
    }


type Message
    = DismissModal
    | Tick Time
    | CancelSubscription
    | ConfirmCancelSubscription
    | SubscriptionCanceled (Result Http.Error User)
    | ReactivateSubscription
    | ConfirmReactivateSubscription
    | SubscriptionReactivated (Result Http.Error User)
