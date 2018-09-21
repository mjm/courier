module Page.Account.Update exposing (update)

import Date
import Http
import Page.Account.Model exposing (Model, Message(..))
import Request.User


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        Tick time ->
            ( { model | now = Date.fromTime time }, Cmd.none )

        CancelSubscription ->
            ( model, Http.send SubscriptionCanceled Request.User.cancelSubscription )

        SubscriptionCanceled (Ok user) ->
            ( { model | user = user }, Cmd.none )

        SubscriptionCanceled (Err _) ->
            ( model, Cmd.none )
