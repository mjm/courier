module Data.PostTweet exposing (..)

import Data.Tweet exposing (Tweet)
import Data.Post exposing (Post)


type alias PostTweet =
    { post : Post
    , tweet : Tweet
    }


fromPost : Post -> List PostTweet
fromPost post =
    List.map (PostTweet post) post.tweets


updateTweet : PostTweet -> Tweet -> PostTweet
updateTweet postTweet tweet =
    if postTweet.tweet.id == tweet.id then
        { postTweet | tweet = tweet }
    else
        postTweet
