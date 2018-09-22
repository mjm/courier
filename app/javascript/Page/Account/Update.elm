module Page.Account.Update exposing (update)

import Date
import Http
import Page.Account.Model exposing (Model, Message(..))
import Request.User
import Views.Modal exposing (Modal)


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        DismissModal ->
            ( { model | modal = Nothing }, Cmd.none )

        Tick time ->
            ( { model | now = Date.fromTime time }, Cmd.none )

        CancelSubscription ->
            ( { model | modal = Just cancelSubscriptionModal }, Cmd.none )

        ConfirmCancelSubscription ->
            ( { model | modal = Nothing }
            , Http.send SubscriptionCanceled Request.User.cancelSubscription
            )

        SubscriptionCanceled (Ok user) ->
            ( { model | user = user }, Cmd.none )

        SubscriptionCanceled (Err _) ->
            ( model, Cmd.none )

        ReactivateSubscription ->
            ( { model | modal = Just reactivateSubscriptionModal }, Cmd.none )

        ConfirmReactivateSubscription ->
            ( { model | modal = Nothing }
            , Http.send SubscriptionReactivated Request.User.reactivateSubscription
            )

        SubscriptionReactivated (Ok user) ->
            ( { model | user = user }, Cmd.none )

        SubscriptionReactivated (Err _) ->
            ( model, Cmd.none )


cancelSubscriptionModal : Modal Message
cancelSubscriptionModal =
    { title = "Are you sure?"
    , body = "Are you sure you want to cancel your subscription? You can resubscribe at any time. Courier will remain usable until your subscription expires."
    , confirmText = "Cancel Subscription"
    , confirmMsg = ConfirmCancelSubscription
    , dismissMsg = DismissModal
    }


reactivateSubscriptionModal : Modal Message
reactivateSubscriptionModal =
    { title = "Are you sure?"
    , body = "Are you sure you want to reactivate your subscription? Your subscription will renew at the end of your current billing period."
    , confirmText = "Reactivate Subscription"
    , confirmMsg = ConfirmReactivateSubscription
    , dismissMsg = DismissModal
    }
