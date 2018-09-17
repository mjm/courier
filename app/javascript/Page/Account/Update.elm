module Page.Account.Update exposing (update)

import Date
import Page.Account.Model exposing (Model, Message(..))


update : Message -> Model -> ( Model, Cmd Message )
update message model =
    case message of
        Tick time ->
            ( { model | now = Date.fromTime time }, Cmd.none )
