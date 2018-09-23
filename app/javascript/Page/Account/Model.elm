module Page.Account.Model exposing (Model, Message(..))

import Data.Event exposing (Event)
import Data.User exposing (User)
import Http
import Page exposing (Page)


type alias Model =
    { stripeKey : String
    , page : Page Message
    }


type Message
    = PageMsg Page.Message
    | EventOccurred Event
    | CancelSubscription
    | ConfirmCancelSubscription
    | SubscriptionCanceled (Result Http.Error User)
    | ReactivateSubscription
    | ConfirmReactivateSubscription
    | SubscriptionReactivated (Result Http.Error User)
