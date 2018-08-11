module Util.Editable exposing (Editable(..), edit, cancel)

{-| When viewing, this simply holds a value.

When editing, we hold an original and the version with the edits.
This way, we can revert back to the original if the operation is canceled.

-}


type Editable a
    = Viewing a
    | Editing a a


transform : (a -> Editable a) -> (a -> a -> Editable a) -> List (Editable a) -> List (Editable a)
transform viewFn editFn =
    List.map
        (\x ->
            case x of
                Viewing x ->
                    viewFn x

                Editing o d ->
                    editFn o d
        )


edit : (a -> Bool) -> List (Editable a) -> List (Editable a)
edit f =
    transform
        (\x ->
            if f x then
                Editing x x
            else
                Viewing x
        )
        Editing


cancel : (a -> Bool) -> List (Editable a) -> List (Editable a)
cancel f =
    transform
        Viewing
        (\x y ->
            if f x then
                Viewing x
            else
                Editing x y
        )
