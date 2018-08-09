module Util exposing (..)

-- I know this is basically just Maybe, but it's more descriptive, especially
-- when the type it contains is also a Maybe.


type Loadable a
    = Loading
    | Loaded a
