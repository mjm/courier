module Util.URL.Regex exposing (findAll, regex)

{-| Finds all of the URLs in a body of text using a regular expression.

The regex itself was adapted from <https://github.com/kevva/url-regex>.

-}

import Regex exposing (HowMany(..), Regex)


regex : Regex
regex =
    "(?:"
        ++ protocol
        ++ "|www\\.)"
        ++ auth
        ++ "(?:localhost|"
        ++ ip
        ++ "|"
        ++ host
        ++ domain
        ++ tld
        ++ ")"
        ++ port_
        ++ path
        |> Regex.regex
        |> Regex.caseInsensitive


findAll : String -> List Regex.Match
findAll =
    Regex.find All regex


protocol : String
protocol =
    "(?:(?:[a-z]+:)?//)?"


auth : String
auth =
    "(?:\\S+(?::\\S*)?@)?"


ip : String
ip =
    "(?:25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]\\d|\\d)(?:\\.(?:25[0-5]|2[0-4]\\d|1\\d\\d|[1-9]\\d|\\d)){3}"


host : String
host =
    "(?:(?:[a-z\\u00a1-\\uffff0-9]-*)*[a-z\\u00a1-\\uffff0-9]+)"


domain : String
domain =
    "(?:\\.(?:[a-z\\u00a1-\\uffff0-9]-*)*[a-z\\u00a1-\\uffff0-9]+)*"


tld : String
tld =
    "(?:\\.(?:[a-z\\u00a1-\\uffff]{2,}))\\.?"


port_ : String
port_ =
    "(?::\\d{2,5})?"


path : String
path =
    "(?:[/?#][^\\s\"]*)?"
