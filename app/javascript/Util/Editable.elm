module Util.Editable exposing (Editable(..), value, edit, updateDraft, cancel, saving, save)

{-| When viewing, this simply holds a value.

When editing, we hold an original and the version with the edits.
This way, we can revert back to the original if the operation is canceled.

-}


type Editable a
    = Viewing a
    | Editing a a
    | Saving a a


value : Editable a -> a
value x =
    case x of
        Viewing x ->
            x

        Editing x _ ->
            x

        Saving x _ ->
            x


transform : (a -> Editable a) -> (a -> a -> Editable a) -> (a -> a -> Editable a) -> List (Editable a) -> List (Editable a)
transform viewFn editFn saveFn =
    List.map
        (\x ->
            case x of
                Viewing x ->
                    viewFn x

                Editing o d ->
                    editFn o d

                Saving o d ->
                    saveFn o d
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
        Saving


updateDraft : (a -> Bool) -> (a -> a) -> List (Editable a) -> List (Editable a)
updateDraft f t =
    transform
        Viewing
        (\x y ->
            if f x then
                Editing x (t y)
            else
                Editing x y
        )
        Saving


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
        (\x y ->
            if f x then
                Viewing x
            else
                Saving x y
        )


saving : (a -> Bool) -> List (Editable a) -> List (Editable a)
saving f =
    transform
        (\x ->
            if f x then
                Saving x x
            else
                Viewing x
        )
        (\x y ->
            if f x then
                Saving x y
            else
                Editing x y
        )
        Saving


save : (a -> Bool) -> (a -> a) -> List (Editable a) -> List (Editable a)
save f t =
    transform
        (\x ->
            if f x then
                Viewing (t x)
            else
                Viewing x
        )
        (\x y ->
            if f x then
                Viewing (t x)
            else
                Editing x y
        )
        (\x y ->
            if f x then
                Viewing (t x)
            else
                Saving x y
        )
