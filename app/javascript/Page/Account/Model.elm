module Page.Account.Model exposing (Message(..), Model)

import Data.User exposing (User)
import Http
import Json.Encode as Encode
import Page exposing (Page)


type alias Model =
    { page : Page Message
    }


type Message
    = PageMsg Page.Message
    | EventOccurred Encode.Value
    | CreateSubscription Encode.Value
    | SubscriptionCreated (Result Http.Error User)
    | OpenPaymentForm
    | Resubscribe
    | CancelSubscription
    | ConfirmCancelSubscription
    | SubscriptionCanceled (Result Http.Error User)
    | ReactivateSubscription
    | ConfirmReactivateSubscription
    | SubscriptionReactivated (Result Http.Error User)
