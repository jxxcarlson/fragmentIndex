module FragmentIndex exposing
    ( Index
    , empty
    , insert
    , insertMany
    , remove
    , removeAll
    , search
    , searchWithList
    )

import MultiDict exposing (MultiDict)
import Set exposing (Set)


type alias Index comparable =
    MultiDict String comparable


prefixLength =
    3


empty =
    MultiDict.empty


normalize : String -> String
normalize str =
    str
        |> String.toLower
        |> String.left prefixLength


insert : String -> comparable -> Index comparable -> Index comparable
insert key value dict =
    MultiDict.insert (normalize key) value dict


remove : String -> comparable -> Index comparable -> Index comparable
remove key value dict =
    MultiDict.remove (normalize key) value dict


removeAll : String -> comparable -> Index comparable -> Index comparable
removeAll str value dict =
    let
        keys =
            str
                |> String.words
                |> List.map (String.left prefixLength)
                |> List.filter (\w -> String.length w >= prefixLength)
    in
    case List.head keys of
        Nothing ->
            dict

        Just firstKey ->
            List.foldl (\key dict_ -> remove key value dict_) (remove firstKey value dict) (List.drop 1 keys)


insertMany : String -> comparable -> Index comparable -> Index comparable
insertMany str value dict =
    let
        keys =
            str
                |> String.words
                |> List.map (String.left prefixLength)
                |> List.filter (\w -> String.length w >= prefixLength)
    in
    List.foldl (\key dict_ -> insert key value dict_) dict keys


{-|

    > search "comp" d
    Set.fromList [2,3,4]
        : Set.Set number
    > search "mus comp" d
    Set.fromList [4] : Set.Set number
    > search "qua" d
    Set.fromList [1,2] : Set.Set number
    > search "qua comp" d
    Set.fromList [2] : Set.Set number

-}
search : String -> Index comparable -> Set comparable
search keyString index =
    searchWithList (String.words keyString) index


searchWithList : List String -> Index comparable -> Set comparable
searchWithList keyList_ index =
    let
        keyList =
            List.map (String.left prefixLength >> normalize) keyList_
    in
    case List.head keyList of
        Nothing ->
            Set.empty

        Just firstKey ->
            List.foldl (\key values -> Set.intersect values (MultiDict.get key index))
                (MultiDict.get firstKey index)
                (List.drop 1 keyList)



-- TEST DATA


d =
    empty
        |> insertMany "Notes on Quantum Mechanics, The Real Deal" 1
        |> insertMany "Foundation of Quantum Computing and Ordinary Computing" 2
        |> insertMany "Intro to Computing Engineering" 3
        |> insertMany "Computational Music" 4
