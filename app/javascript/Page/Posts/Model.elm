module Page.Posts.Model exposing (Model, Message(..))

import ActionCable exposing (ActionCable)
import ActionCable.Identifier as ID
import ActionCable.Msg as ACMsg
import Data.Tweet exposing (Tweet)
import Data.User exposing (User)
import Date exposing (Date)
import Http
import Json.Decode as Decode
import Time exposing (Time)
import Util.Editable exposing (Editable(..))


type alias Model =
    { tweets : List (Editable Tweet)
    , user : User
    , errors : List String
    , now : Date
    , cable : ActionCable Message
    }


type Message
    = CableMsg ACMsg.Msg
    | Subscribe ()
    | HandleSocketData ID.Identifier Decode.Value
    | DismissError String
    | Tick Time
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
