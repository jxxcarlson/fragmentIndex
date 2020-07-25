# FragmentIndex  

FragmentIndex provides the means to do rapid conjunctive
searches on fragments of key words.  By way of example,
we will create an index for a set books, where we are  
given the titles of the books and an integer ID:

```
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
```


Then we can do searches like this:

```
> search "intro" testData
Set.fromList [3,5,6]

> search "intro music" testData
Set.fromList [5]

> search "mus introduction" testData
Set.fromList [5]
```

When we say `insert keyString ID Dict`, the `keyString` is broken into a
list of words, then each word is normalized to a lower case prefix of
length three.  Thus "Quantum" becomes "qua".  Finally, words of length
less than three are discarded.  Then we do `MultiDict.insert prefix ID`
repeatedly for each of the prefixes.

## Discussion

To get an idea of why using short prefixes of keywords might be a good
idea, consider the experiment below.  Of 235,886 words in a standard list,
there were 4,051 3-prefixes and 22,068 4-prefixes. The number of combinations
of two 3-prefixes is 8,203,275, and the number of combinations of three
3-prefixes is 11,071,686,825.  Thus in principle, small sets of short
prefixes can discriminate between many objects.  Of course the prefix sets  
occurring in real day are not randomly distributed, so the disciminating
power in practice is considerably less.

```
$ wc -l /usr/share/dict/words
235886 /usr/share/dict/words

$ cat /usr/share/dict/words | cut -c -3 \
| tr '[:upper:]' '[:lower:]' | uniq | wc -l
4051
```
