
/usr/share/dict/words

$ cat words | cut -c -4 > prefixes | tr '[:upper:]' '[:lower:]' | uniq > prefix-4

235886 words
4051 3-prefixes
22068 4-prefixes
