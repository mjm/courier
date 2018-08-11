module Page.Feeds.Main exposing (main)

import Data.Feed as Feed exposing (Feed)
import Data.User as User exposing (User)
import Html
import Json.Decode exposing (decodeValue)
import Page.Feeds.Flags exposing (Flags)
import Page.Feeds.Model as Model exposing (Model)
import Page.Feeds.Update exposing (Message(..), update)
import Page.Feeds.View exposing (view)
import Unwrap
import Util.Loadable exposing (Loadable(Loaded))


init : Flags -> ( Model, Cmd Message )
init flags =
    { user = Just (userFromFlags flags)
    , feeds = Loaded (feedsFromFlags flags)
    , draftFeed = Nothing
    , errors = []
    }
        ! []


feedsFromFlags : Flags -> List Feed
feedsFromFlags flags =
    decodeValue Feed.listDecoder flags.feeds
        |> Unwrap.result


userFromFlags : Flags -> User
userFromFlags flags =
    decodeValue User.decoder flags.user
        |> Unwrap.result


subscriptions : Model -> Sub Message
subscriptions model =
    Sub.none


main : Program Flags Model Message
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
