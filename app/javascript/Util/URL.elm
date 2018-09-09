module Util.URL exposing (displayUrl)


displayUrl : String -> String
displayUrl url =
    stripScheme url
        |> stripTrailingSlash


stripScheme : String -> String
stripScheme url =
    if String.startsWith "http://" url then
        String.dropLeft 7 url
    else if String.startsWith "https://" url then
        String.dropLeft 8 url
    else
        url


stripTrailingSlash : String -> String
stripTrailingSlash url =
    if String.endsWith "/" url then
        String.dropRight 1 url
    else
        url
