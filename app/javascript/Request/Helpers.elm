module Request.Helpers exposing (..)

import HttpBuilder


apiMethodUrl : String -> String
apiMethodUrl =
    (++) "/courier.Api/"


apiBuilder : String -> HttpBuilder.RequestBuilder ()
apiBuilder method =
    apiMethodUrl method |> HttpBuilder.post
