module Request.User exposing (..)

import Data.User as User exposing (User)
import Http
import HttpBuilder exposing (withExpect, withJsonBody, toRequest)
import Json.Decode as Decode
import Json.Encode as Encode
import Request.Helpers exposing (apiBuilder)


usersBuilder : String -> HttpBuilder.RequestBuilder ()
usersBuilder =
    apiBuilder "Users"


userDecoder : Decode.Decoder User
userDecoder =
    Decode.field "user" User.decoder


cancelSubscription : Http.Request User
cancelSubscription =
    usersBuilder "CancelSubscription"
        |> withJsonBody (Encode.object [])
        |> withExpect (Http.expectJson userDecoder)
        |> toRequest
