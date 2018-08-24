module Page.Posts.Update exposing (update)

import ActionCable
import ActionCable.Identifier as ID
import Data.Post exposing (Post)
import Data.PostTweet as PostTweet exposing (PostTweet)
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
            ActionCable.update msg model.cable
                |> (\( cable, cmd ) -> { model | cable = cable } ! [ cmd ])

        Subscribe () ->
            subscribeTo model

        HandleSocketData id value ->
            case Decode.decodeValue Tweet.decoder value of
                Ok tweet ->
                    ( { model | tweets = saveTweet tweet model.tweets }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        UserLoaded (Ok user) ->
            ( { model | user = user }, Cmd.none )

        UserLoaded (Err _) ->
            ( model, Cmd.none )

        PostsLoaded (Ok posts) ->
            ( { model | tweets = tweetsFromPosts posts }, Cmd.none )

        PostsLoaded (Err _) ->
            ( model, Cmd.none )

        Tick time ->
            ( { model | now = Date.fromTime time }, Cmd.none )

        CancelTweet tweet ->
            ( model, Http.send CanceledTweet <| Request.Tweet.cancel tweet )

        CanceledTweet (Ok tweet) ->
            ( updateTweet tweet model, Cmd.none )

        CanceledTweet (Err _) ->
            ( model, Cmd.none )

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
            ( model, Cmd.none )

        SubmitTweet tweet ->
            ( { model | tweets = savingTweet tweet model.tweets }, Http.send TweetSubmitted (Request.Tweet.post tweet) )

        TweetSubmitted (Ok tweet) ->
            ( { model | tweets = saveTweet tweet model.tweets }, Cmd.none )

        TweetSubmitted (Err _) ->
            ( model, Cmd.none )


subscribeTo : Model -> ( Model, Cmd Message )
subscribeTo model =
    case ActionCable.subscribeTo (ID.newIdentifier "PostsChannel" []) model.cable of
        Ok ( cable, cmd ) ->
            ( { model | cable = cable }, cmd )

        Err err ->
            ( model, Cmd.none )


tweetsFromPosts : List Post -> List (Editable PostTweet)
tweetsFromPosts posts =
    List.concatMap (PostTweet.fromPost) posts
        |> List.map Viewing


updateTweet : Tweet -> Model -> Model
updateTweet tweet model =
    let
        updatedTweets =
            List.map (updatePostTweet tweet) model.tweets
    in
        { model | tweets = updatedTweets }


updatePostTweet : Tweet -> Editable PostTweet -> Editable PostTweet
updatePostTweet tweet postTweet =
    case postTweet of
        Viewing t ->
            Viewing (PostTweet.updateTweet t tweet)

        Editing orig edit ->
            Editing (PostTweet.updateTweet orig tweet) edit

        Saving orig edit ->
            Saving (PostTweet.updateTweet orig tweet) edit


editTweet : Tweet -> List (Editable PostTweet) -> List (Editable PostTweet)
editTweet t =
    Editable.edit (\x -> x.tweet.id == t.id)


updateDraftTweet : (Tweet -> Tweet) -> Tweet -> List (Editable PostTweet) -> List (Editable PostTweet)
updateDraftTweet f t =
    Editable.updateDraft
        (\x -> x.tweet.id == t.id)
        (\x -> { x | tweet = f x.tweet })


cancelEditTweet : Tweet -> List (Editable PostTweet) -> List (Editable PostTweet)
cancelEditTweet t =
    Editable.cancel (\x -> x.tweet.id == t.id)


savingTweet : Tweet -> List (Editable PostTweet) -> List (Editable PostTweet)
savingTweet t =
    Editable.saving (\x -> x.tweet.id == t.id)


saveTweet : Tweet -> List (Editable PostTweet) -> List (Editable PostTweet)
saveTweet t =
    Editable.save
        (\x -> x.tweet.id == t.id)
        (\x -> { x | tweet = t })
