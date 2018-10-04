module Request.User exposing (cancelSubscription, createSubscription, reactivateSubscription, userDecoder, usersBuilder)

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


createSubscription : String -> String -> Http.Request User
createSubscription email token =
    let
        body =
            Encode.object
                [ ( "email", Encode.string email )
                , ( "tokenId", Encode.string token )
                ]
    in
    usersBuilder "CreateSubscription"
        |> withJsonBody body
        |> withExpect (Http.expectJson userDecoder)
        |> toRequest


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
