module Page.Posts.Model exposing (Message(..), Model)

import Data.Event exposing (Event)
import Data.Tweet exposing (Tweet)
import Http
import Json.Encode as Encode
import Page exposing (Page)
import Util.Editable exposing (Editable(..))
import Util.ExpandingList exposing (ExpandingList)


type alias Model =
    { upcomingTweets : ExpandingList (Editable Tweet)
    , pastTweets : ExpandingList (Editable Tweet)
    , page : Page Message
    }


type Message
    = PageMsg Page.Message
    | EventOccurred Encode.Value
    | ExpandUpcomingTweets
    | ExpandPastTweets
    | CancelTweet Tweet
    | CanceledTweet (Result Http.Error Tweet)
    | UncancelTweet Tweet
    | UncanceledTweet (Result Http.Error Tweet)
    | EditTweet Tweet
    | SetTweetBody Tweet String
    | CancelEditTweet Tweet
    | SaveTweet Tweet Bool
    | TweetSaved (Result Http.Error Tweet)
    | SubmitTweet Tweet
    | TweetSubmitted (Result Http.Error Tweet)
