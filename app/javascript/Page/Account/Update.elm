module Page.Account.Update exposing (update)

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Page
import Page.Account.Model exposing (Message(..), Model)
import Page.Helper exposing (addError, dismissModal, modalInProgress, showModal)
import Request.User


update : Cmd Message -> Message -> Model -> ( Model, Cmd Message )
update openPaymentForm message model =
    case message of
        PageMsg msg ->
            handlePageMessage msg model

        EventOccurred _ ->
            ( model, Cmd.none )

        CreateSubscription value ->
            handleCreateSubscription value model

        SubscriptionCreated (Ok user) ->
            ( { model | page = Page.updateUser model.page user }, Cmd.none )

        SubscriptionCreated (Err _) ->
            ( addError model "Could not create your subscription right now. Please try again later.", Cmd.none )

        OpenPaymentForm ->
            ( model, openPaymentForm )

        CancelSubscription ->
            ( showModal model cancelSubscriptionModal, Cmd.none )

        ConfirmCancelSubscription ->
            ( modalInProgress model
            , Http.send SubscriptionCanceled Request.User.cancelSubscription
            )

        SubscriptionCanceled (Ok user) ->
            ( dismissModal { model | page = Page.updateUser model.page user }, Cmd.none )

        SubscriptionCanceled (Err _) ->
            ( dismissModal model, Cmd.none )

        ReactivateSubscription ->
            ( showModal model reactivateSubscriptionModal, Cmd.none )

        ConfirmReactivateSubscription ->
            ( modalInProgress model
            , Http.send SubscriptionReactivated Request.User.reactivateSubscription
            )

        SubscriptionReactivated (Ok user) ->
            ( dismissModal { model | page = Page.updateUser model.page user }, Cmd.none )

        SubscriptionReactivated (Err _) ->
            ( dismissModal model, Cmd.none )


paymentDecoder : Decoder ( String, String )
paymentDecoder =
    Decode.map2 Tuple.pair
        (Decode.field "email" Decode.string)
        (Decode.field "id" Decode.string)


handleCreateSubscription : Encode.Value -> Model -> ( Model, Cmd Message )
handleCreateSubscription value model =
    case Decode.decodeValue paymentDecoder value of
        Ok ( email, token ) ->
            ( model
            , Http.send SubscriptionCreated
                (Request.User.createSubscription email token)
            )

        Err _ ->
            ( model, Cmd.none )


handlePageMessage : Page.Message -> Model -> ( Model, Cmd Message )
handlePageMessage msg model =
    let
        ( page, cmd ) =
            Page.update msg model.page
    in
    ( { model | page = page }, cmd )


cancelSubscriptionModal : Page.Modal Message
cancelSubscriptionModal =
    { title = "Are you sure?"
    , body = "Are you sure you want to cancel your subscription? You can resubscribe at any time. Courier will remain usable until your subscription expires."
    , confirmText = "Cancel Subscription"
    , confirmMsg = ConfirmCancelSubscription
    }


reactivateSubscriptionModal : Page.Modal Message
reactivateSubscriptionModal =
    { title = "Are you sure?"
    , body = "Are you sure you want to reactivate your subscription? Your subscription will renew at the end of your current billing period."
    , confirmText = "Reactivate Subscription"
    , confirmMsg = ConfirmReactivateSubscription
    }
