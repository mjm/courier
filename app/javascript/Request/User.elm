module Request.User exposing (cancelSubscription, reactivateSubscription, userDecoder, usersBuilder)

import Data.User as User exposing (User)
import Http
import HttpBuilder exposing (toRequest, withExpect, withJsonBody)
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


reactivateSubscription : Http.Request User
reactivateSubscription =
    usersBuilder "ReactivateSubscription"
        |> withJsonBody (Encode.object [])
        |> withExpect (Http.expectJson userDecoder)
        |> toRequest
