module Request.Translate exposing (translate)

import Data.Post as Post exposing (Post)
import Data.Tweet as Tweet exposing (Tweet)
import Http
import HttpBuilder exposing (withExpect, withJsonBody, toRequest)
import Request.Helpers exposing (apiBuilder)


translate : Post -> Http.Request Tweet
translate post =
    apiBuilder "Translate"
        |> withJsonBody (Post.encode post)
        |> withExpect (Http.expectJson Tweet.decoder)
        |> toRequest
