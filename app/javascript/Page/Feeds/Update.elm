module Page.Feeds.Update exposing (Message(..), update)

import Data.Feed exposing (Feed, DraftFeed)
import Data.User exposing (User)
import Dom
import Http
import Page.Feeds.Model exposing (Model)
import Request.Feed
import Task


type Message
    = Noop
    | DismissError String
    | UserLoaded (Result Http.Error User)
    | FeedsLoaded (Result Http.Error (List Feed))
    | SetAddingFeed Bool
    | SetDraftFeedUrl String
    | AddFeed
    | FeedAdded (Result Http.Error Feed)
    | RefreshFeed Feed
    | FeedRefreshed (Result Http.Error ())
    | UpdateAutoposting Feed Bool
    | SettingsUpdated (Result Http.Error Feed)


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        Noop ->
            ( model, Cmd.none )

        DismissError err ->
            ( removeError model err, Cmd.none )

        UserLoaded (Ok user) ->
            ( { model | user = user }, Cmd.none )

        UserLoaded (Err _) ->
            ( addError model "Could not your user profile. Please try again later.", Cmd.none )

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
