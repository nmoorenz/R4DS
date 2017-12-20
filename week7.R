# week 7 Strings

library(tidyverse)
library(stringr)


#14.2 String Basics

string1 <- "This is a string"
string2 <- 'This is also a string with "quotes" inside'
string3 <- "Including a \\ requires doubling up"
string3
writeLines(string3)

# stringr has a bunch of good functions beginning with str_
str_length(string2)

# combine two strings
str_c("x", "yyy")
str_c("x", "yyy", sep = ", ")

# collapse vector of strings with collapse
str_c(c("x", "y", "z"), collapse = ", ")

# subsetting strings
x <- c("Apple", "Banana", "Pear")
# of course vectorised
str_sub(x, 1, 3)
# and works backwards
str_sub(x, -3, -1)
# can use assignment form to change strings
str_sub(x, 1, 1) <- str_to_lower(str_sub(x, 1, 1))
x

# locale might be important in some circumstances
# use en for English language

# 14.2.5 Exercises
# 1
?paste
# same as str_c, coerces NA to show

# 2
# sep works to combine different strings, collapse takes items in a vector

# 3 
str_sub(string1, str_length(string1)/2, str_length(string1)/2)
# automatically takes one before the middle character

# 4
?str_wrap
# when space is limited or creating a markdown document

# 5
?str_trim
# take out whitespace

# 6 
# come back to this one


############

# 14.3 Matching patterns with regular expressions
?str_view

x <- c("apple", "banana", "pear")

# match exact strings
str_view(x, "an")

# match any character except newline with .
str_view(x, ".a.")

# find an actual .
str_view(c("abc", "a.c", "bef"), "a.c") # not this!
str_view(c("abc", "a.c", "bef"), "a\.c") # error
str_view(c("abc", "a.c", "bef"), "a\\.c") # has to be this

# find a \ (one backslash is represented by 2, so need 4!)
str_view("a\\b", "\\\\")

# 14.3.1.1 Exercises
# 1
# backslashes are a mess

# 2 
y <- "\"'\\"
y
writeLines(y)
str_view(y, "\"'\\\\")

# 3
z <- ".a.b.c"
z
writeLines(z)
str_view(z, "\\..\\..\\..")

# 14.3.2 Anchors

# ^ for start of string, $ for end of string
x <- c("apple", "banana", "pear")
str_view(x, "^a")
str_view(x, "a$")

# to find complete string, start with ^ and finish with $
y <- c("apple pie", "apple", "apple cake")
str_view(y, "apple")
str_view(y, "^apple$")

# 14.3.2.1 Exercises
# 1 
f <- "$^$"
f
str_view(f, "\\$\\^\\$")

# 2 
str_view(stringr::words, "^y", match = TRUE)
str_view(stringr::words, "x$", match = TRUE)
str_view(stringr::words, "^...$", match = TRUE)
str_view(stringr::words, "^.......", match = TRUE)

# 14.3.3 character class and alternatives
# \d digit
# \s whitespace
# [abc] matches a, b, or c
# [^abc] matches anything except a, b, or c
# | for OR

# 14.3.3.1 Exercises
# 1 
str_view(stringr::words, "^[aeiou]", match = TRUE)
str_view(stringr::words, "^[^aeiou]", match = TRUE)
str_view(stringr::words, "[^e]ed$", match = TRUE)
str_view(stringr::words, "ed$", match = TRUE)
str_view(stringr::words, "ing|ise$", match = TRUE)

# 2
str_view(stringr::words, "cie", match = TRUE)
str_view(stringr::words, "cei", match = TRUE)

# 3
str_view(stringr::words, "q[^u]", match = TRUE)

# 4 british not american english
str_view(stringr::words, "ou", match = TRUE)
# remove u from a word, can you find that word in stringr::words

# 5 
str_view(x, "(\d\d)\d\d\d-\d\d\d\d")

# 14.3.4 Repetition

# ?   0 or 1
# +   1 or more
# *   0 or more

x <- "1888 is the longest year in Roman numerals: MDCCCLXXXVIII"
str_view(x, "CC?")
str_view(x, "CC+")
str_view(x, "C[LX]+")

# specify numbers directly
# {n}   exactly n
# {n,}  n or more
# {,m}  at most m
# {n,m} between n and m

str_view(x, "C{2}")
str_view(x, "C{2,}")
str_view(x, "C{2,3}")

# 14.3.4.1 Exercises
# ? = {0,1}
# + = {1,}
# * = {0,}

# 2 
# ^.*$ matches any word (start, any length of characters, end)
# "\\{.+\\}" matches curly, 1 or more characters, curly
# \d{4}-\d{2}-\d{2} matches 4 digits, dash, 2 digits, 2 digits
# "\\\\{4}" matches four backslash

# 3 
str_view(stringr::words, "^[^aeiou]{3}", match = TRUE)
str_view(stringr::words, "[aeiou]{3}", match = TRUE)
str_view(stringr::words, "([aeiou][^aeiou]){2,}", match = TRUE)


# 14.3.5 Grouping and backreferences
# find repeated references
str_view(fruit, "(..)\\1", match = TRUE)

# 14.3.5.1 Exercises
# 1 
str_view(stringr::words, "(.)(.)(.).*\\3\\2\\1", match = TRUE)
# (.)\1\1 matches any character repeated three times
# "(.)(.)\\2\\1" matches eppe for example (1)(2)\2\1
# (..)\1 matches two characters, repeated
# "(.).\\1.\\1" matches b{anana} and p{apaya} (1).(1).(1)
# "(.)(.)(.).*\\3\\2\\1" matches (1)(2)(3).*(3)(2)(1) eg {par}ag{rap}h

# 2 
str_view(stringr::words, "^(.).*\\1$", match = TRUE)
str_view(stringr::words, "(..).*\\1", match = TRUE)
str_view(stringr::words, "(.).*\\1.*\\1", match = TRUE)


# 14.4 Tools
# regex can be difficult!

# 14.4.1 Detect matches
x <- c("apple", "banana", "pear")
str_detect(x, "e")

# sum how many matches there are in a vector
sum(str_detect(words, "^t"))

mean(str_detect(words, "[aeiou]$"))

# combine logical conditions 
# inverse of any words that contain a vowel
no_vowels_1 <- !str_detect(words, "[aeiou]")
# words that don't contain a vowel
no_vowels_2 <- str_detect(words, "^[^aeiou]+$")
# these are the same but first is easier
identical(no_vowels_1, no_vowels_2)

# str_subset for getting list of words
str_subset(words, "^[^aeiou]+$")

# might want to use filter to get a data frame
df <- tibble(
  word = words, 
  i = seq_along(word)
)

df %>% 
  filter(str_detect(words, "x$"))

# str_count for counting matches
x <- c("apple", "banana", "pear")
str_count(x, "a")

# str_count and mutate
df %>% 
  mutate(
    vowels = str_count(word, "[aeiou]"), 
    consonants = str_count(word, "[^aeiou]")
  )

# 14.4.2 Exercises
# 1 
str_subset(words, "^x*.*x$*")
# 2
str_subset(words, "^[aeiou].*[^aeiou]$")

# 3
dfw <- tibble(
  word = words, 
  i = seq_along(word)
)

dfw %>% 
  mutate(
    a = str_count(word, "a"), 
    e = str_count(word, "e"), 
    i = str_count(word, "i"), 
    o = str_count(word, "o"), 
    u = str_count(word, "u"), 
    tot = a+e+i+o+u
  ) %>% 
  filter(tot >= 5)

# 2

dfv <- tibble(
  word = words, 
  i = seq_along(word)
)

dfv %>% 
  mutate(
    vowel = str_count(word, "[aeiou]"), 
    tot = str_length(word), 
    prop = vowel / tot
  ) %>% 
  arrange(desc(prop))

# 14.4.3 Extract matches
length(sentences)
head(sentences)

colours <- c("\\sred", "orange", "yellow", "green", "blue", "purple")
colour_match <- str_c(colours, collapse = "|\\s")

has_colour <- str_subset(sentences, colour_match)
matches <- str_extract(has_colour, colour_match)
head(matches)

more <- sentences[str_count(sentences, colour_match) > 1]
str_view_all(more, colour_match)

str_extract(more, colour_match)
str_extract_all(more, colour_match, simplify = TRUE)

# 14.4.3.1 Exercises
# 1 edited to include white space 

# 2 first word from each sentence
str_extract(sentences, "^[A-Za-z]+\\s")

end_ing <- str_subset(sentences, "[A-Za-z]+ing\\s")
ending <- str_trim(str_extract(end_s, "[A-Za-z]+ing\\s"))
head(ending)

end_s <- str_subset(sentences, "[A-Za-z]+s\\s")
enders <- str_extract_all(end_s, "[A-Za-z]+s\\s", simplify = TRUE)
enders2 <- gather(as.tibble(enders))

wordsall = str_c(words, collapse = "|")
enders3 <- str_subset(enders, wordsall)

head(enders3)

# 14.4.4 Grouped Matches

noun <- "(a|the) ([^ ]+)"

has_noun <- sentences %>% 
  str_subset(noun) %>% 
  head(10)

has_noun %>% 
  str_extract(noun)

has_noun %>% 
  str_match(noun)

# tidyr::extract
tibble(sentence = sentences) %>% 
  tidyr::extract(
    sentence, c("article", "noun"), "(a|the) ([^ ]+)",
    remove = FALSE
  )

# 14.4.4.1 Exercises
numbers <- "( )(one|two|three|four|five|six|seven|eight|nine|ten|zero) ([^ ]+)"

has_number <- sentences %>% 
  str_subset(numbers)

head(has_number)

has_number %>% 
  str_match(numbers)

# contractions
cont <- "([^ ]+)'([^ s]+)"

has_cont <- sentences %>% 
  str_subset(cont)

head(has_cont)

has_cont %>% 
  str_match(cont)

# 14.4.5 Replacing Matches
x <- c("apple", "banana", "pear")
str_replace(x, "[aeiou]", "-")
str_replace_all(x, "[aeiou]", "-")

# vector for multiple replacements
x <- c("1 house", "2 cars", "3 people")
str_replace_all(x, c("1" = "one", "2" = "two", "3" = "three"))

sentences %>% 
  str_replace("([^ ]+) ([^ ]+) ([^ ]+)", "\\1 \\3 \\2") %>% 
  head(5)

# 14.5.1 Exercises
# 1
g <- "this / might / be / difficult"

h <- str_replace_all(g, "/", "\\\\")
writeLines(h)


# 2 str_to_lower

sentences %>% 
  str_replace_all("[A-Z]", "[a-z]")

# first and last letters
words %>% 
  str_replace("([A-Za-z])([a-z]*)([a-z])", "\\3\\2\\1")


# 14.4.6 Splitting

sentences %>%
  head(5) %>% 
  str_split(" ", simplify = TRUE)

x <- "This is a sentence.  This is another sentence."
str_view_all(x, boundary("word"))

str_split(x, " ")[[1]]
str_split(x, boundary("word"))[[1]]

"apples, pears, and bananas" %>% 
  str_split(boundary("word"), simplify = TRUE)

"" %>% 
  str_split(boundary("word"), simplify = TRUE)


# 14.5 Other Types of Pattern

# The regular call:
str_view(fruit, "nana")
# Is shorthand for
str_view(fruit, regex("nana"))

# use options for regex to get other matches
bananas <- c("banana", "Banana", "BANANA")
str_view(bananas, "banana")
str_view(bananas, regex("banana", ignore_case = TRUE))

x <- "Line 1\nLine 2\nLine 3"
str_extract_all(x, "^Line")[[1]]
str_extract_all(x, regex("^Line", multiline = TRUE))[[1]]

# can format so more understandable
phone <- regex("
  \\(?     # optional opening parens
  (\\d{3}) # area code
  [)- ]?   # optional closing parens, dash, or space
  (\\d{3}) # another three numbers
  [ -]?    # optional space or dash
  (\\d{3}) # three more numbers
  ", comments = TRUE)

str_match("514-791-8141", phone)

# instead of regex use fixed()
microbenchmark::microbenchmark(
  fixed = str_detect(sentences, fixed("the")),
  regex = str_detect(sentences, "the"),
  times = 20
)

# human collation rules with coll()
i <- c("I", "I", "i", "i")
str_subset(i, coll("i", ignore_case = TRUE))
str_subset(i, coll("i", ignore_case = TRUE, locale = "tr"))

# locale
stringi::stri_locale_info()

# 14.5.1 Exercises
w_in_s <- str_to_lower(sentences) %>%
  str_split(boundary("word"), simplify = TRUE) 

words_ <- as.data.frame(w_in_s) %>% 
  gather() %>% 
  group_by(value) %>% 
  summarise(counter = n()) %>% 
  arrange(desc(counter))

stop_words <- as.data.frame(str_to_lower(words), col.names = "words")

words_L <- words_ %>% 
  anti_join(stop_words, by = c("value" = "str_to_lower(words)"))

#####
# 14.6 Other uses of regular expressions

apropos("replace")

head(dir(pattern = "\\.Rmd$"))

#####
# 14.7 stringi

?stringi
stri_count_words()
stri_duplicated() 
stri_rand_lipsum()
