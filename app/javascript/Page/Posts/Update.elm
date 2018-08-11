module Page.Posts.Update exposing (Message(..), update)

import Data.Post exposing (Post)
import Data.PostTweet as PostTweet exposing (PostTweet)
import Data.Tweet exposing (Tweet)
import Data.User exposing (User)
import Page.Posts.Model exposing (Model)
import Http
import Request.Post
import Util.Editable as Editable exposing (Editable(..))


type Message
    = UserLoaded (Result Http.Error User)
    | PostsLoaded (Result Http.Error (List Post))
    | CancelTweet Tweet
    | CanceledTweet (Result Http.Error Tweet)
    | EditTweet Tweet
    | SetTweetBody Tweet String
    | CancelEditTweet Tweet
    | SaveTweet Tweet


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        UserLoaded (Ok user) ->
            ( { model | user = user }, Cmd.none )

        UserLoaded (Err _) ->
            ( model, Cmd.none )

        PostsLoaded (Ok posts) ->
            ( { model | tweets = tweetsFromPosts posts }, Cmd.none )

        PostsLoaded (Err _) ->
            ( model, Cmd.none )

        CancelTweet tweet ->
            ( model, Http.send CanceledTweet <| Request.Post.cancelTweet tweet )

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

        SaveTweet tweet ->
            ( { model | tweets = saveTweet tweet model.tweets }, Cmd.none )


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


saveTweet : Tweet -> List (Editable PostTweet) -> List (Editable PostTweet)
saveTweet t =
    Editable.save
        (\x -> x.tweet.id == t.id)
        (\x -> { x | tweet = t })
