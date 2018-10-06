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


wrap : Int -> List a -> ExpandingList a
wrap =
    ExpandingList


replace : List a -> ExpandingList a -> ExpandingList a
replace is xs =
    { xs | items = is }


expand : Int -> ExpandingList a -> ExpandingList a
expand n xs =
    { xs | limit = xs.limit + n }


items : ExpandingList a -> List a
items xs =
    List.take xs.limit xs.items


isEmpty : ExpandingList a -> Bool
isEmpty xs =
    List.isEmpty xs.items


hasMore : ExpandingList a -> Bool
hasMore xs =
    List.length xs.items > xs.limit


map : (a -> b) -> ExpandingList a -> List b
map f xs =
    List.map f (items xs)
