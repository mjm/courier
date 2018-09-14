module Page.Posts.Update exposing (update)

import ActionCable
import ActionCable.Msg as ACMsg
import ActionCable.Identifier as ID
import Data.Event as Event exposing (Event(..))
import Data.Tweet as Tweet exposing (Tweet)
import Date exposing (Date)
import Page.Posts.Model exposing (Model, Message(..))
import Http
import Json.Decode as Decode
import Request.Tweet
import Util.Editable as Editable exposing (Editable(..))


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        CableMsg msg ->
            handleCableMessage msg model

        Subscribe () ->
            subscribe model

        HandleSocketData id value ->
            handleSocketData id value model

        DismissError error ->
            ( removeError model error, Cmd.none )

        Tick time ->
            ( { model | now = Date.fromTime time }, Cmd.none )

        CancelTweet tweet ->
            ( model, Http.send CanceledTweet <| Request.Tweet.cancel tweet )

        CanceledTweet (Ok tweet) ->
            ( updateTweet tweet model, Cmd.none )

        CanceledTweet (Err _) ->
            ( addError model "Could not cancel posting the tweet right now. Please try again later.", Cmd.none )

        EditTweet tweet ->
            ( { model | tweets = editTweet tweet model.tweets }, Cmd.none )

        SetTweetBody tweet body ->
            let
                updater =
                    \x -> { x | body = body }
            in
                ( { model | tweets = updateDraftTweet updater tweet model.tweets }, Cmd.none )

        CancelEditTweet tweet ->
            ( { model | tweets = cancelEditTweet tweet model.tweets }, Cmd.none )

        SaveTweet tweet shouldPost ->
            ( { model | tweets = savingTweet tweet model.tweets }, Http.send TweetSaved (Request.Tweet.update tweet shouldPost) )

        TweetSaved (Ok tweet) ->
            ( { model | tweets = saveTweet tweet model.tweets }, Cmd.none )

        TweetSaved (Err _) ->
            ( addError model "Could not save the tweet right now. Please try again later.", Cmd.none )

        SubmitTweet tweet ->
            ( { model | tweets = savingTweet tweet model.tweets }, Http.send TweetSubmitted (Request.Tweet.post tweet) )

        TweetSubmitted (Ok tweet) ->
            ( { model | tweets = saveTweet tweet model.tweets }, Cmd.none )

        TweetSubmitted (Err _) ->
            ( addError model "Could not post the tweet right now. Please try again later.", Cmd.none )


handleCableMessage : ACMsg.Msg -> Model -> ( Model, Cmd Message )
handleCableMessage msg model =
    ActionCable.update msg model.cable
        |> (\( cable, cmd ) -> { model | cable = cable } ! [ cmd ])


subscribe : Model -> ( Model, Cmd Message )
subscribe model =
    case ActionCable.subscribeTo (ID.newIdentifier "EventsChannel" []) model.cable of
        Ok ( cable, cmd ) ->
            ( { model | cable = cable }, cmd )

        Err err ->
            ( model, Cmd.none )


handleSocketData : ID.Identifier -> Decode.Value -> Model -> ( Model, Cmd Message )
handleSocketData id value model =
    case Decode.decodeValue Event.decoder value of
        Ok event ->
            handleEvent event model

        Err _ ->
            ( model, Cmd.none )


handleEvent : Event -> Model -> ( Model, Cmd Message )
handleEvent event model =
    case event of
        TweetUpdated tweet ->
            ( { model | tweets = saveTweet tweet model.tweets }, Cmd.none )


updateTweet : Tweet -> Model -> Model
updateTweet tweet model =
    let
        updatedTweets =
            List.map (updatePostTweet tweet) model.tweets
    in
        { model | tweets = updatedTweets }


updatePostTweet : Tweet -> Editable Tweet -> Editable Tweet
updatePostTweet tweet existing =
    case existing of
        Viewing t ->
            Viewing (Tweet.update t tweet)

        Editing orig edit ->
            Editing (Tweet.update orig tweet) edit

        Saving orig edit ->
            Saving (Tweet.update orig tweet) edit


editTweet : Tweet -> List (Editable Tweet) -> List (Editable Tweet)
editTweet t =
    Editable.edit (\x -> x.id == t.id)


updateDraftTweet : (Tweet -> Tweet) -> Tweet -> List (Editable Tweet) -> List (Editable Tweet)
updateDraftTweet f t =
    Editable.updateDraft (\x -> x.id == t.id) f


cancelEditTweet : Tweet -> List (Editable Tweet) -> List (Editable Tweet)
cancelEditTweet t =
    Editable.cancel (\x -> x.id == t.id)


savingTweet : Tweet -> List (Editable Tweet) -> List (Editable Tweet)
savingTweet t =
    Editable.saving (\x -> x.id == t.id)


saveTweet : Tweet -> List (Editable Tweet) -> List (Editable Tweet)
saveTweet t =
    Editable.save
        (\x -> x.id == t.id)
        (\_ -> t)


addError : Model -> String -> Model
addError model err =
    { model | errors = (err :: model.errors) }


removeError : Model -> String -> Model
removeError model err =
    let
        errors =
            List.filter (\e -> not (e == err)) model.errors
    in
        { model | errors = errors }
