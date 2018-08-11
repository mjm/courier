module Util exposing (..)

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


{-| When viewing, this simply holds a value.

When editing, we hold an original and the version with the edits.
This way, we can revert back to the original if the operation is canceled.

-}
type Editable a
    = Viewing a
    | Editing a a
