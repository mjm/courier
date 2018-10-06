module Page.Posts.Update exposing (update)

import Data.Account as Account
import Data.Event as Event exposing (Event(..))
import Data.Tweet as Tweet exposing (Tweet)
import Http
import Json.Decode exposing (decodeValue)
import Json.Encode as Encode
import Page
import Page.Posts.Model exposing (Message(..), Model)
import Request.Tweet
import Util.Editable as Editable exposing (Editable(..))
import Util.ExpandingList as EList exposing (ExpandingList)


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        PageMsg msg ->
            handlePageMessage msg model

        EventOccurred event ->
            handleEvent event model

        ExpandUpcomingTweets ->
            ( { model | upcomingTweets = EList.expand 10 model.upcomingTweets }, Cmd.none )

        ExpandPastTweets ->
            ( { model | pastTweets = EList.expand 10 model.pastTweets }, Cmd.none )

        CancelTweet tweet ->
            ( model, Http.send CanceledTweet <| Request.Tweet.cancel tweet )

        CanceledTweet (Ok tweet) ->
            ( updateTweet tweet model, Cmd.none )

        CanceledTweet (Err _) ->
            ( addError model "Could not cancel posting the tweet right now. Please try again later.", Cmd.none )

        UncancelTweet tweet ->
            ( model, Http.send UncanceledTweet <| Request.Tweet.uncancel tweet )

        UncanceledTweet (Ok tweet) ->
            ( updateTweet tweet model, Cmd.none )

        UncanceledTweet (Err _) ->
            ( addError model "Could not undo canceling posting the tweet right now. Please try again later.", Cmd.none )

        EditTweet tweet ->
            ( updateTweets (editTweet tweet) model, Cmd.none )

        SetTweetBody tweet body ->
            let
                updater =
                    \x -> { x | body = body }
            in
            ( updateTweets (updateDraftTweet updater tweet) model, Cmd.none )

        CancelEditTweet tweet ->
            ( updateTweets (cancelEditTweet tweet) model, Cmd.none )

        SaveTweet tweet shouldPost ->
            let
                isActive =
                    Account.isActive model.page.user model.page.now

                reallyPost =
                    isActive && shouldPost
            in
            ( updateTweets (savingTweet tweet) model
            , Http.send TweetSaved (Request.Tweet.update tweet reallyPost)
            )

        TweetSaved (Ok tweet) ->
            ( updateTweets (saveTweet tweet) model, Cmd.none )

        TweetSaved (Err _) ->
            ( addError model "Could not save the tweet right now. Please try again later.", Cmd.none )

        SubmitTweet tweet ->
            if Account.isActive model.page.user model.page.now then
                ( updateTweets (savingTweet tweet) model
                , Http.send TweetSubmitted (Request.Tweet.post tweet)
                )

            else
                ( model, Cmd.none )

        TweetSubmitted (Ok tweet) ->
            ( updateTweets (saveTweet tweet) model, Cmd.none )

        TweetSubmitted (Err _) ->
            ( addError model "Could not post the tweet right now. Please try again later.", Cmd.none )


handlePageMessage : Page.Message -> Model -> ( Model, Cmd Message )
handlePageMessage msg model =
    let
        ( page, cmd ) =
            Page.update msg model.page
    in
    ( { model | page = page }, cmd )


handleEvent : Encode.Value -> Model -> ( Model, Cmd Message )
handleEvent eventValue model =
    case decodeValue Event.decoder eventValue of
        Ok event ->
            case event of
                TweetUpdated tweet ->
                    ( updateTweets (saveTweet tweet) model, Cmd.none )

                TweetCreated tweet ->
                    ( updateTweets (addTweet tweet) model, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Err _ ->
            ( model, Cmd.none )


allTweets : Model -> List (Editable Tweet)
allTweets model =
    EList.items model.upcomingTweets ++ EList.items model.pastTweets


setTweets : List (Editable Tweet) -> Model -> Model
setTweets tweets model =
    let
        upcoming =
            Tweet.upcoming tweets

        past =
            Tweet.past tweets
    in
    { model
        | upcomingTweets = EList.replace upcoming model.upcomingTweets
        , pastTweets = EList.replace past model.pastTweets
    }


updateTweets : (List (Editable Tweet) -> List (Editable Tweet)) -> Model -> Model
updateTweets f model =
    setTweets (f (allTweets model)) model


addTweet : Tweet -> List (Editable Tweet) -> List (Editable Tweet)
addTweet tweet ts =
    List.sortWith
        (\a b -> Tweet.compare (Editable.value a) (Editable.value b))
        (Viewing tweet :: ts)


updateTweet : Tweet -> Model -> Model
updateTweet tweet =
    updateTweets (List.map (updatePostTweet tweet))


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
    { model | page = Page.addError model.page err }


removeError : Model -> String -> Model
removeError model err =
    { model | page = Page.removeError model.page err }
