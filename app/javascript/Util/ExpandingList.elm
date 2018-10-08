module Util.ExpandingList exposing
    ( ExpandingList, wrap
    , replace, expand
    , items, isEmpty, hasMore, map
    )

{-| ExpandingList wraps a normal list with conveniences to make it easier to show a subset of the list items.


# Definition

@docs ExpandingList, wrap


# Updating the List

@docs replace, expand


# Querying the List

@docs items, isEmpty, hasMore, map

-}


type alias ExpandingList a =
    { limit : Int
    , items : List a
    }


{-| Wrap a list in an expanding list, showing a limited number of items.

    items (wrap 2 [ 1, 2, 3 ]) == [ 1, 2 ]

-}
wrap : Int -> List a -> ExpandingList a
wrap =
    ExpandingList


{-| Update the items an expanding list can show.

Replaces the full set of items for the list, while preserving the current limit.

    replace [ 4, 5, 6 ] (wrap 2 [ 1, 2, 3 ]) == wrap 2 [ 4, 5, 6 ]

-}
replace : List a -> ExpandingList a -> ExpandingList a
replace is xs =
    { xs | items = is }


{-| Increase the limit of an expanding list, so the list will show more items.

    expand 2 (wrap 2 [ 1, 2, 3 ]) == wrap 4 [ 1, 2, 3 ]

-}
expand : Int -> ExpandingList a -> ExpandingList a
expand n xs =
    { xs | limit = xs.limit + n }


{-| Gets the list of items the list is currently showing.

    items (wrap 2 [ 1, 2, 3 ]) == [ 1, 2 ]

-}
items : ExpandingList a -> List a
items xs =
    List.take xs.limit xs.items


{-| Returns True is there are no items in the expanding list.

    isEmpty (wrap 2 []) == True

    isEmpty (wrap 2 [ 1, 2, 3 ]) == False

-}
isEmpty : ExpandingList a -> Bool
isEmpty xs =
    List.isEmpty xs.items


{-| Returns True if the expanding list has more items that it is currently showing.

    hasMore (wrap 2 [ 1, 2, 3 ]) == True

    hasMore (wrap 2 [ 1, 2 ]) == False

-}
hasMore : ExpandingList a -> Bool
hasMore xs =
    List.length xs.items > xs.limit


{-| Maps a function over the currently visible items in the expanding list.

    map (\x -> x * 2) (wrap 2 [ 1, 2, 3 ]) == [ 2, 4 ]

-}
map : (a -> b) -> ExpandingList a -> List b
map f xs =
    List.map f (items xs)
