module Request.Helpers exposing (apiBuilder, apiMethodUrl)

import HttpBuilder


apiMethodUrl : String -> String -> String
apiMethodUrl service method =
    "/api/" ++ service ++ "/" ++ method


apiBuilder : String -> String -> HttpBuilder.RequestBuilder ()
apiBuilder service method =
    apiMethodUrl service method |> HttpBuilder.post
