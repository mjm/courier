module Request.User exposing (getUserInfo)

import Data.User as User exposing (User)
import Http
import HttpBuilder exposing (withExpect, withJsonBody, toRequest)
import Json.Encode as Encode
import Request.Helpers exposing (apiBuilder)


getUserInfo : Http.Request User
getUserInfo =
    apiBuilder "GetUserInfo"
        |> withJsonBody (Encode.object [])
        |> withExpect (Http.expectJson User.decoder)
        |> toRequest
