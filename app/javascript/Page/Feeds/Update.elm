module Page.Feeds.Update exposing (update)

import Data.Event as Event exposing (Event(..))
import Data.Feed as Feed exposing (DraftFeed, Feed)
import Http
import Json.Decode exposing (decodeValue)
import Json.Encode as Encode
import Page
import Page.Feeds.Model exposing (Message(..), Model)
import Page.Helper exposing (addError, dismissModal, modalInProgress, showModal)
import Request.Feed


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        Noop ->
            ( model, Cmd.none )

        PageMsg msg ->
            handlePageMessage msg model

        EventOccurred event ->
            handleEvent event model

        SetAddingFeed isAdding ->
            if isAdding then
                ( { model | draftFeed = Just (DraftFeed "") }, Cmd.none )

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
            ( showModal model (deleteFeedModal feed), Cmd.none )

        ConfirmDeleteFeed feed ->
            ( modalInProgress model
            , Http.send (FeedDeleted feed) (Request.Feed.delete feed)
            )

        FeedDeleted feed (Ok _) ->
            ( dismissModal { model | feeds = deleteFeed feed model.feeds }
            , Cmd.none
            )

        FeedDeleted feed (Err _) ->
            ( dismissModal <| addError model "Could not delete the feed right now. Please try again later."
            , Cmd.none
            )


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
                FeedUpdated feed ->
                    ( { model | feeds = updateFeed feed model.feeds }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Err _ ->
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


deleteFeedModal : Feed -> Page.Modal Message
deleteFeedModal feed =
    { title = "Are you sure?"
    , body = "Are you sure you want to delete the feed \"" ++ Feed.displayName feed ++ "\"?"
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
