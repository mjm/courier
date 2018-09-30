module Util.Loadable exposing (Loadable(..), map)

{-| I know this is basically just Maybe, but it's more descriptive, especially
when the type it contains is also a Maybe.
-}


type Loadable a
    = Loading
    | Loaded a


map : (a -> a) -> Loadable a -> Loadable a
map f l =
    case l of
        Loading ->
            Loading

        Loaded x ->
            Loaded (f x)
