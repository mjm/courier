module Views.Linkify exposing (linkify)

{-| Transforms the URLs in a body of text into HTML links.
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Regex exposing (Match)
import Util.URL.Regex as URLs


linkify : String -> List (Html msg)
linkify text =
    List.map toHtml (tokenize text)


type Token
    = Text String
    | URL String


type alias Tokenizer =
    { start : Int
    , indices : List Indices
    }


type alias Indices =
    { start : Int
    , mid : Int
    , end : Int
    }


tokenize : String -> List Token
tokenize text =
    List.concatMap (createTokens text) <|
        tokenIndices (String.length text) (URLs.findAll text)


createTokens : String -> Indices -> List Token
createTokens text i =
    let
        token =
            makeToken text
    in
        (token Text i.start i.mid) ++ (token URL i.mid i.end)


makeToken : String -> (String -> Token) -> Int -> Int -> List Token
makeToken text f start end =
    if start == end then
        []
    else
        [ f (String.slice start end text) ]


tokenIndices : Int -> List Match -> List Indices
tokenIndices len ms =
    let
        t =
            List.foldl
                advance
                { start = 0, indices = [] }
                ms
    in
        if t.start == len then
            t.indices
        else
            t.indices ++ [ { start = t.start, mid = len, end = len } ]


advance : Match -> Tokenizer -> Tokenizer
advance m t =
    let
        end =
            m.index + (String.length m.match)

        next =
            { start = t.start, mid = m.index, end = end }
    in
        { start = end, indices = t.indices ++ [ next ] }


toHtml : Token -> Html msg
toHtml token =
    case token of
        Text str ->
            text str

        URL url ->
            a
                [ href url
                , target "_blank"
                ]
                [ text url ]
