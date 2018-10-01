module Page.Account.Model exposing (Message(..), Model)

import Data.User exposing (User)
import Http
import Json.Encode as Encode
import Page exposing (Page)


type alias Model =
    { stripeKey : String
    , page : Page Message
    }


type Message
    = PageMsg Page.Message
    | EventOccurred Encode.Value
    | CancelSubscription
    | ConfirmCancelSubscription
    | SubscriptionCanceled (Result Http.Error User)
    | ReactivateSubscription
    | ConfirmReactivateSubscription
    | SubscriptionReactivated (Result Http.Error User)
