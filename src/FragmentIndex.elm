module FragmentIndex exposing
    ( FragmentIndex, testData, empty, insert, insertOne, remove, removeOne, search, searchWithList
    , size
    )

{-| FragmentIndex provides a kind of dictionary for making rapid conjunctive searches.

@docs FragmentIndex, testData, empty, insert, insertOne, remove, removeOne, search, searchWithList

-}

import MultiDict exposing (MultiDict)
import Set exposing (Set)


{-| A MultiDict (Janiczek/elm-bidict) whose keys are strings and whose
values are comparables, e.g, strings or integers.
-}
type alias FragmentIndex comparable =
    MultiDict String comparable


{-|

    Keys stored in the index are truncatd to three characters.
    Keys must have three characters.

-}
prefixLength =
    3


{-| Create empty FragmentIndex
-}
empty : FragmentIndex comparable
empty =
    MultiDict.empty


{-| Get size of index.
-}
size : FragmentIndex comparable -> Int
size index =
    MultiDict.size index


{-|

    > insertOne "foobar" 77 empty
    MultiDict (Dict.fromList [("foo",Set.fromList [77])])

-}
insertOne : String -> comparable -> FragmentIndex comparable -> FragmentIndex comparable
insertOne key value dict =
    MultiDict.insert (normalize key) value dict


{-|

    > insert "Introduction to General Magic" 717 empty
    MultiDict (Dict.fromList [("gen",Set.fromList [717]),("int",Set.fromList [717]),("mag",Set.fromList [717])])

-}
insert : String -> comparable -> FragmentIndex comparable -> FragmentIndex comparable
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

    > insertOne "foobar" 77 empty |> removeOne "foobar" 77
    MultiDict (Dict.fromList [])

-}
removeOne : String -> comparable -> FragmentIndex comparable -> FragmentIndex comparable
removeOne key value dict =
    MultiDict.remove (normalize key) value dict


{-|

    > d |> remove "Comp Music" 4 |> search "comp"
    Set.fromList [2,3]

-}
remove : String -> comparable -> FragmentIndex comparable -> FragmentIndex comparable
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


{-|

    > search "comp" testData
    Set.fromList [2,3,4]
        : Set.Set number
    > search "mus comp" testData
    Set.fromList [4] : Set.Set number
    > search "qua" testData
    Set.fromList [1,2] : Set.Set number
    > search "qua comp" testData
    Set.fromList [2] : Set.Set number

-}
search : String -> FragmentIndex comparable -> Set comparable
search keyString index =
    searchWithList (String.words keyString) index


{-|

    > searchWithList ["mus", "comp"] testData
    Set.fromList [4]

-}
searchWithList : List String -> FragmentIndex comparable -> Set comparable
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


{-| Some test data
-}
testData : FragmentIndex Int
testData =
    empty
        |> insert "Quantum Mechanics, The Real Deal" 1
        |> insert "Foundations of Quantum Computing" 2
        |> insert "Intro to Computer Engineering" 3
        |> insert "Computer Music" 4
        |> insert "Introduction to Music Theory" 5
        |> insert "Card Tricks, an Introductory Tutorial" 6
        |> insert "Card Games and Board Games" 7
