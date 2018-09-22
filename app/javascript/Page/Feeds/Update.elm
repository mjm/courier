module Page.Feeds.Update exposing (update)

import ActionCable
import ActionCable.Msg as ACMsg
import ActionCable.Identifier as ID
import Data.Event as Event exposing (Event(..))
import Data.Feed as Feed exposing (Feed, DraftFeed)
import Date
import Dom
import Http
import Json.Decode as Decode
import Page.Feeds.Model exposing (Model, Modal, Message(..))
import Request.Feed
import Task


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        Noop ->
            ( model, Cmd.none )

        CableMsg msg ->
            handleCableMessage msg model

        Subscribe () ->
            subscribe model

        HandleSocketData id value ->
            handleSocketData id value model

        DismissError err ->
            ( removeError model err, Cmd.none )

        DismissModal ->
            ( { model | modal = Nothing }, Cmd.none )

        Tick time ->
            ( { model | now = Date.fromTime time }, Cmd.none )

        FeedsLoaded (Ok feeds) ->
            ( { model | feeds = feeds }, Cmd.none )

        FeedsLoaded (Err _) ->
            ( addError model "Could not load your feeds right now. Please try again later.", Cmd.none )

        SetAddingFeed isAdding ->
            if isAdding then
                ( { model | draftFeed = Just (DraftFeed "") }
                , Task.attempt (\_ -> Noop) (Dom.focus "add-feed-url")
                )
            else
                ( { model | draftFeed = Nothing }, Cmd.none )

        SetDraftFeedUrl url ->
            ( { model | draftFeed = updateFeedUrl model.draftFeed url }, Cmd.none )

        AddFeed ->
            case model.draftFeed of
                Just feed ->
                    ( { model | draftFeed = Nothing }
                    , Http.send FeedAdded (Request.Feed.register feed)
                    )

                Nothing ->
                    ( model, Cmd.none )

        FeedAdded (Ok feed) ->
            ( { model | feeds = addFeed feed model.feeds }, Cmd.none )

        FeedAdded (Err _) ->
            ( addError model "Could not add the feed right now. Please try again later.", Cmd.none )

        RefreshFeed feed ->
            ( model, Http.send FeedRefreshed (Request.Feed.refresh feed) )

        FeedRefreshed (Ok _) ->
            ( model, Cmd.none )

        FeedRefreshed (Err _) ->
            ( addError model "Could not refresh the feed right now. Please try again later.", Cmd.none )

        UpdateAutoposting feed enabled ->
            ( model, Http.send SettingsUpdated (Request.Feed.updateSettings feed { autopost = Just enabled }) )

        SettingsUpdated (Ok feed) ->
            ( { model | feeds = updateFeed feed model.feeds }, Cmd.none )

        SettingsUpdated (Err _) ->
            ( addError model "Could not update the feed settings right now. Please try again later.", Cmd.none )

        DeleteFeed feed ->
            ( { model | modal = Just (deleteFeedModal feed) }, Cmd.none )

        ConfirmDeleteFeed feed ->
            ( { model | modal = Nothing }, Http.send (FeedDeleted feed) (Request.Feed.delete feed) )

        FeedDeleted feed (Ok _) ->
            ( { model | feeds = deleteFeed feed model.feeds }, Cmd.none )

        FeedDeleted feed (Err _) ->
            ( addError model "Could not delete the feed right now. Please try again later.", Cmd.none )


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
        FeedUpdated feed ->
            ( { model | feeds = updateFeed feed model.feeds }, Cmd.none )

        _ ->
            ( model, Cmd.none )


addFeed : Feed -> List Feed -> List Feed
addFeed feed fs =
    fs ++ [ feed ]


updateFeed : Feed -> List Feed -> List Feed
updateFeed feed fs =
    List.map
        (\f ->
            if f.id == feed.id then
                feed
            else
                f
        )
        fs


deleteFeed : Feed -> List Feed -> List Feed
deleteFeed feed fs =
    List.filter (\f -> f.id /= feed.id) fs


deleteFeedModal : Feed -> Modal
deleteFeedModal feed =
    { title = "Are you sure?"
    , body = "Are you sure you want to delete the feed \"" ++ (Feed.displayName feed) ++ "\"?"
    , confirmText = "Delete Feed"
    , confirmMsg = ConfirmDeleteFeed feed
    }


updateFeedUrl : Maybe DraftFeed -> String -> Maybe DraftFeed
updateFeedUrl feed url =
    case feed of
        Just draftFeed ->
            Just { draftFeed | url = url }

        Nothing ->
            Just (DraftFeed url)


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
