module FragmentIndex exposing
    ( Index
    , d
    , empty
    , insert
    , insertOne
    , remove
    , removeOne
    , search
    , searchWithList
    )

import MultiDict exposing (MultiDict)
import Set exposing (Set)


type alias Index comparable =
    MultiDict String comparable


{-|

    Keys stored in the index are truncatd to three characters.
    Keys must have three characters.

-}
prefixLength =
    3


{-| Create empty FragmentIndex
-}
empty =
    MultiDict.empty


{-|

    > insert "Introduction to General Magic" 717 empty
    MultiDict (Dict.fromList [("gen",Set.fromList [717]),("int",Set.fromList [717]),("mag",Set.fromList [717])])

-}
insert : String -> comparable -> Index comparable -> Index comparable
insert str value dict =
    let
        keys =
            str
                |> String.words
                |> List.map (String.left prefixLength)
                |> List.filter (\w -> String.length w >= prefixLength)
    in
    List.foldl (\key dict_ -> insertOne key value dict_) dict keys


{-|

    > d |> remove "Comp Music" 4 |> search "comp"
    Set.fromList [2,3]

-}
remove : String -> comparable -> Index comparable -> Index comparable
remove str value dict =
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
            List.foldl (\key dict_ -> removeOne key value dict_) (removeOne firstKey value dict) (List.drop 1 keys)


normalize : String -> String
normalize str =
    str
        |> String.toLower
        |> String.left prefixLength


insertOne : String -> comparable -> Index comparable -> Index comparable
insertOne key value dict =
    MultiDict.insert (normalize key) value dict


removeOne : String -> comparable -> Index comparable -> Index comparable
removeOne key value dict =
    MultiDict.remove (normalize key) value dict


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
        |> insert "Notes on Quantum Mechanics, The Real Deal" 1
        |> insert "Foundation of Quantum Computing and Ordinary Computing" 2
        |> insert "Intro to Computing Engineering" 3
        |> insert "Computer Music" 4
