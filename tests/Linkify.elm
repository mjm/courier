module Linkify exposing (suite)

import Expect
import Html
import Html.Attributes exposing (href, target)
import Test exposing (..)
import Views.Linkify exposing (linkify)


suite : Test
suite =
    describe "Linkifying URLs in text"
        [ describe "text with no URLs in it"
            [ test "returns HTML with the text unchanged" <|
                \() ->
                    "This is some example text."
                        |> linkify
                        |> Expect.equal [ Html.text "This is some example text." ]
            ]
        , describe "text that is only a URL"
            [ test "returns an anchor tag with a link to the URL" <|
                \() ->
                    "https://example.com/foo/bar/"
                        |> linkify
                        |> Expect.equal
                            [ Html.a
                                [ href "https://example.com/foo/bar/"
                                , target "_blank"
                                ]
                                [ Html.text "https://example.com/foo/bar/" ]
                            ]
            ]
        , describe "some text with URLs mixed in"
            [ test "returns HTML with anchors for the URLs" <|
                \() ->
                    "This is text. https://example.org/\n\nhttps://example.com/feed/ And some more text"
                        |> linkify
                        |> Expect.equal
                            [ Html.text "This is text. "
                            , Html.a
                                [ href "https://example.org/"
                                , target "_blank"
                                ]
                                [ Html.text "https://example.org/" ]
                            , Html.text "\n\n"
                            , Html.a
                                [ href "https://example.com/feed/"
                                , target "_blank"
                                ]
                                [ Html.text "https://example.com/feed/" ]
                            , Html.text " And some more text"
                            ]
            ]
        ]
