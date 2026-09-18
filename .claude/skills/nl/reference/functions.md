# newLISP Spark — Built-in Function Reference

Condensed from `doc/newlisp_manual.html` (newLISP Spark v10.7.6s1).
Full details, examples and edge cases: `doc/newlisp_manual.html` (repo)
or `/usr/local/share/doc/newlisp/newlisp_manual.html` (installed).

Predicate names end in `?`. In syntax lines, `<angle-bracket>` words denote
argument roles (`str`=string, `int`=integer, `num`=number, `list`=list,
`sym`=symbol, `ctx`=context, `exp`=any expression, `place`=settable place,
`func`=function, `body`=sequence of expressions). Some functions are
listed under more than one category when they work on several types.

## List processing, flow control, and integer arithmetic

### `+, -, *, / ,%`
```lisp
(+ int-1 [int-2 ... ])
(- int-1 [int-2 ... ])
(* int-1 [int-2 ... ])
(/ int-1 [int-2 ... ])
(% int-1 [int-2 ... ])
```
Returns the sum of all numbers in int-1 —.

### `++`
```lisp
(++ place [num ... ])
```
The ++ operator works like inc, but performs integer arithmetic. Without the optional argument in num, ++ increments the number in place by 1.

### `--`
```lisp
(-- place [num ... ])
```
The -- operator works like dec, but performs integer arithmetic. Without the optional argument in num-2, -- decrements the number in place by 1.

### `<, >, =, <=, >=, !=`
```lisp
(< exp-1 [exp-2 ... ])
(> exp-1 [exp-2 ... ])
(= exp-1 [exp-2 ... ])
(<= exp-1 [exp-2 ... ])
(>= exp-1 [exp-2 ... ])
(!= exp-1 [exp-2 ... ])
```
Expressions are evaluated and the results are compared successively. As long as the comparisons conform to the comparison operators, evaluation and comparison will continue until all arguments are tested and the result is true.

### `:`
```lisp
(: sym-function list-object [ ... ])
```
The colon is used not only as a syntactic separator between namespace prefix and the term inside but also as an operator.

### `and`
```lisp
(and exp-1 [exp-2 ... ])
```
The expressions exp-1, exp-2, etc. are evaluated in order, returning the result of the last expression. If any of the expressions yield nil or the empty list (), evaluation is terminated and nil or the empty list () is returned.

### `append`
```lisp
(append list-1 [list-2 ... ])
(append array-1 [array-2 ... ])
(append str-1 [str-2 ... ])
```
In the first form, append works with lists, appending list-1 through list-n to form a new list. The original lists are left unchanged.

### `apply`
```lisp
(apply func list [int-reduce])
(apply func)
```
Applies the contents of func (primitive, user-defined function, or lambda expression) to the arguments in list. Only functions and operators with standard evaluation of their arguments can be applied.

### `args`
```lisp
(args)
(args int-idx-1 [int-idx-2 ... ])
```
Accesses a list of all unbound arguments passed to the currently evaluating define, define-macro lambda, or lambda-macro expression.

### `assoc`
```lisp
(assoc exp-key list-alist)
(assoc list-exp-key list-alist)
```
In the first syntax the value of exp-key is used to search list-alist for a member-list whose first element matches the key value. If found, the member-list is returned; otherwise, the result will be nil.

### `begin`
```lisp
(begin body)
```
The begin function is used to group a block of expressions. The expressions in body are evaluated in sequence, and the value of the last expression in body is returned.

### `bigint`
```lisp
(bigint number)
(bigint string)
```
A floating point or integer number gets converted to big integer format. When converting from floating point, rounding errors occur going back and forth between decimal and binary arithmetic.

### `bind`
```lisp
(bind list-variable-associations [bool-eval])
```
list-variable-associations contains an association list of symbols and their values. bind sets all symbols to their associated values.

### `case`
```lisp
(case exp-switch (exp-1 body-1) [(exp-2 body-2) ... ])
```
The result of evaluating exp-switch is compared to each of the unevaluated expressions exp-1, exp-2, —.

### `catch`
```lisp
(catch exp)
(catch exp symbol)
```
In the first syntax, catch will return the result of the evaluation of exp or the evaluated argument of a throw executed during the evaluation of exp:

### `chop`
```lisp
(chop str [int-chars])
(chop list [int-elements])
```
If the first argument evaluates to a string, chop returns a copy of str with the last int-char characters omitted. If the int-char argument is absent, one character is omitted. chop does not alter str.

### `clean`
```lisp
(clean exp-predicate list)
```
The predicate exp-predicate is applied to each element of list. In the returned list, all elements for which exp-predicate is true are eliminated.

### `collect`
```lisp
(collect exp [int-max-count])
```
Evaluates the expression in exp and collects the results in a list until evaluation of exp returns nil.

### `cond`
```lisp
(cond (exp-condition-1 body-1) [(exp-condition-2 body-2) ... ])
```
Like if, cond conditionally evaluates the expressions within its body. The exp-conditions are evaluated in turn, until some exp-condition-i is found that evaluates to anything other than nil or an empty list ().

### `cons`
```lisp
(cons exp-1 exp-2)
```
If exp-2 evaluates to a list, then a list is returned with the result of evaluating exp-1 inserted as the first element.

### `constant`
```lisp
(constant sym-1 exp-1 [sym-2 exp-2] ...)
```
Identical to set in functionality, constant further protects the symbols from subsequent modification.

### `count`
```lisp
(count list-1 list-2)
```
Counts elements of list-1 in list-2 and returns a list of those counts.

### `curry`
```lisp
(curry func exp)
```
Transforms func from a function f(x, y) that takes two arguments into a function fx(y) that takes a single argument. curry works like a macro in that it does not evaluate its arguments. Instead, they are evaluated during the application of func.

### `define`
```lisp
(define (sym-name [sym-param-1 ... ]) [body-1 ... ])
(define (sym-name [(sym-param-1 exp-default) ... ]) [body-1 ... ])
(define sym-name exp)
```
Defines the new function sym-name, with optional parameters sym-param-1—. define is equivalent to assigning a lambda expression to sym-name.

### `define-macro`
```lisp
(define-macro (sym-name [sym-param-1 ... ]) body)
(define-macro (sym-name [(sym-param-1 exp-default) ... ]) body)
```
Functions defined using define-macro are called fexpr in other LISPs as they don't do variable expansion.

### `def-new`
```lisp
(def-new sym-source [sym-target])
```
This function works similarly to new, but it only creates a copy of one symbol and its contents from the symbol in sym-source.

### `difference`
```lisp
(difference list-A list-B)
(difference list-A list-B bool)
```
In the first syntax, difference returns the set difference between list-A and list-B.

### `doargs`
```lisp
(doargs (sym [exp-break]) body)
```
Iterates through all members of the argument list inside a user-defined function or macro.

### `dolist`
```lisp
(dolist (sym list|array [exp-break]) body)
```
The expressions in body are evaluated for each element in list or array. The variable in sym is set to each of the elements before evaluation of the body expressions.

### `dostring`
```lisp
(dostring (sym string [exp-break]) body)
```
The expressions in body are evaluated for each character in string. The variable in sym is set to each ASCII or UTF-8 integer value of the characters before evaluation of the body expressions.

### `dotimes`
```lisp
(dotimes (sym-var int-count [exp-break]) body)
```
The expressions in body are evaluated int times. The variable in sym is set from 0 (zero) to (int - 1) each time before evaluating the body expression(s).

### `dotree`
```lisp
(dotree (sym sym-context [bool]) body)
```
The expressions in body are evaluated for all symbols in sym-context. The symbols are accessed in a sorted order.

### `do-until`
```lisp
(do-until exp-condition [body])
```
The expressions in body are evaluated before exp-condition is evaluated. If the evaluation of exp-condition is not nil, then the do-until expression is finished; otherwise, the expressions in body get evaluated again.

### `do-while`
```lisp
(do-while exp-condition body)
```
The expressions in body are evaluated before exp-condition is evaluated. If the evaluation of exp-condition is nil, then the do-while expression is finished; otherwise the expressions in body get evaluated again.

### `dup`
```lisp
(dup exp int-n [bool])
(dup exp)
```
If the expression in exp evaluates to a string, it will be replicated int-n times within a string and returned.

### `ends-with`
```lisp
(ends-with str-data str-key [num-option])
(ends-with list exp)
```
In the first syntax, ends-with tests the string in str-data to see if it ends with the string specified in str-key. It returns true or nil depending on the outcome.

### `eval`
```lisp
(eval exp)
```
eval evaluates the result of evaluating exp in the current variable environment.

### `exists`
```lisp
(exists func-condition list)
```
Successively applies func-condition to the elements of list and returns the first element that meets the condition in func-condition. If no element meets the condition, nil is returned.

### `expand`
```lisp
(expand exp sym-1 [sym-2 ... ])
(expand exp list-assoc [bool])
(expand exp)
(expand list list-assoc [bool])
(expand list)
```
In the first syntax, one symbol in sym (or more in sym-2 through sym-n) is looked up in a simple or nested expression exp. They are then expanded to the current binding of the symbol and the expanded expression is returned. The original list remains unchanged.

### `explode`
```lisp
(explode str [int-chunk [bool]])
(explode list [int-chunk [bool]])
```
In the first syntax, explode transforms the string (str) into a list of single-character strings.

### `extend`
```lisp
(extend list-1 [list-2 ... ])
(extend string-1 [string-2 ... ])
```
The list in list-1 is extended by appending list-2. More than one list may be appended.

### `first`
```lisp
(first list)
(first array)
(first str)
```
Returns the first element of a list or the first character of a string. The operand is not changed. This function is equivalent to car or head in other Lisp dialects.

### `filter`
```lisp
(filter exp-predicate exp-list)
```
The predicate exp-predicate is applied to each element of the list exp-list. A list is returned containing the elements for which exp-predicate is true. filter works like clean, but with a negated predicate.

### `find`
```lisp
(find exp-key list [func-compare | regex-option])
(find str-key str-data [regex-option [int-offset]])
```
If the second argument evaluates to a list, then find returns the index position (offset) of the element derived from evaluating exp-key.

### `flat`
```lisp
(flat list [int-level])
```
Returns a flattened list from a list:

### `fn`
```lisp
(fn (list-parameters) exp-body)
```
fn or lambda are used to define anonymous functions, which are frequently used in map, sort, and all other expressions where functions can be used as arguments.

### `for`
```lisp
(for (sym num-from num-to [num-step [exp-break]]) body)
```
Repeatedly evaluates the expressions in body for a range of values specified in num-from and num-to, inclusive. A step size may be specified with num-step. If no step size is specified, 1 is assumed.

### `for-all`
```lisp
(for-all func-condition list)
```
Applies the function in func-condition to all elements in list. If all elements meet the condition in func-condition, the result is true; otherwise, nil is returned.

### `if`
```lisp
(if exp-condition exp-1 [exp-2])
(if exp-cond-1 exp-1 exp-cond-2 exp-2 [ ... ])
```
If the value of exp-condition is neither nil nor an empty list, the result of evaluating exp-1 is returned; otherwise, the value of exp-2 is returned. If exp-2 is absent, the value of exp-condition is returned.

### `if-not`
```lisp
(if-not exp-condition exp-1 [exp-2])
```
if-not is equivalent to (if (not exp-condition exp-1 [exp-2])). If the value of exp-condition is nil or the empty list (), exp-1 is evaluated; otherwise, the optional exp-2 is evaluated.

### `index`
```lisp
(index exp-predicate exp-list)
```
Applies the predicate exp-predicate to each element of the list exp-list and returns a list containing the indices of the elements for which exp-predicate is true.

### `intersect`
```lisp
(intersect list-A list-B)
(intersect list-A list-B bool)
```
In the first syntax, intersect returns a list containing one copy of each element found both in list-A and list-B.

### `last`
```lisp
(last list)
(last array)
(last str)
```
Returns the last element of a list or a string.

### `length`
```lisp
(length exp)
```
Returns the number of elements in a list, the number of rows in an array and the number of bytes in a string or in a symbol name.

### `let`
```lisp
(let ((sym1 [exp-init1]) [(sym2 [exp-init2]) ... ]) body)
(let (sym1 exp-init1 [sym2 exp-init2 ... ]) body)
```
One or more variables sym1, sym2, ... are declared locally and initialized with expressions in exp-init1, exp-init2, etc. In the fully parenthesized first syntax, initializers are optional and assumed nil if missing.

### `letex`
```lisp
(letex ((sym1 [exp-init1]) [(sym2 [exp-init2]) ... ]) body)
(letex (sym1 exp-init1 [sym2 exp-init2 ... ]) body)
```
This function combines let and expand to expand local variables into an expression before evaluating it. In the fully parenthesized first syntax initializers are optional and assumed nil if missing.

### `letn`
```lisp
(letn ((sym1 [exp-init1]) [(sym2 [exp-init2]) ... ]) body)
(letn (sym1 exp-init1 [sym2 exp-init2 ... ]) body)
```
letn is like a nested let and works similarly to let, but will incrementally use the new symbol bindings when evaluating the initializer expressions as if several let were nested.

### `list`
```lisp
(list exp-1 [exp-2 ... ])
```
The exp are evaluated and the values used to construct a new list. Note that arguments of array type are converted to lists. See the chapter Arrays for dealing with multidimensional lists.

### `local`
```lisp
(local (sym-1 [sym-2 ... ]) body)
```
Initializes one or more symbols in sym-1— to nil, evaluates the expressions in body, and returns the result of the last evaluation.

### `lookup`
```lisp
(lookup exp-key list-assoc [int-index [exp-default]])
```
Finds in list-assoc an association, the key element of which has the same value as exp-key, and returns the int-index element of association (or the last element if int-index is absent).

### `map`
```lisp
(map exp-functor list-args-1 [list-args-2 ... ])
```
Successively applies the primitive function, defined function, or lambda expression exp-functor to the arguments specified in list-args-1 list-args-2—, returning all results in a list.

### `match`
```lisp
(match list-pattern list-match [bool])
```
The pattern in list-pattern is matched against the list in list-match, and the matching expressions are returned in a list. The three wildcard characters ?, +, and * can be used in list-pattern.

### `member`
```lisp
(member exp list)
(member str-key str [num-option])
```
In the first syntax, member searches for the element exp in the list list. If the element is a member of the list, a new list starting with the element found and the rest of the original list is constructed and returned.

### `not`
```lisp
(not exp)
```
If exp evaluates to nil or the empty list (), then true is returned; otherwise, nil is returned.

### `nth`
```lisp
(nth int-index list)
(nth int-index array)
(nth int-index str)
(nth list-indices list)
(nth list-indices array)
```
In the first syntax group nth uses int-index an index into the list, array or str found and returning the element found at that index. See also Indexing elements of strings and lists.

### `or`
```lisp
(or exp-1 [exp-2 ... ])
```
Evaluates expressions exp-x from left to right until finding a result that does not evaluate to nil or the empty list (). The result is the return value of the or expression.

### `pop`
```lisp
(pop list [int-index-1 [int-index-2 ... ]])
(pop list [list-indexes])
(pop str [int-index [int-length]])
```
Using pop, elements can be removed from lists and characters from strings.

### `pop-assoc`
```lisp
(pop-assoc exp-key list-assoc)
(pop-assoc list-keys list-assoc)
```
Removes an association referred to by the key in exp-key from the association list in list-assoc and returns the popped expression.

### `push`
```lisp
(push exp list [int-index-1 [int-index-2 ... ]])
(push exp list [list-indexes])
(push str-1 str-2 [int-index])
```
Inserts the value of exp into the list list. If int-index is present, the element is inserted at that index.

### `quote`
```lisp
(quote exp)
```
Returns exp without evaluating it. The same effect can be obtained by prepending a ' (single quote) to exp. The function quote is resolved during runtime, the prepended ' quote is translated into a protective envelope (quote cell) during code translation.

### `ref`
```lisp
(ref exp-key list [func-compare [true]])
```
ref searches for the key expression exp-key in list and returns a list of integer indices or an empty list if exp-key cannot be found. ref can work together with push and pop, both of which can also take lists of indices.

### `ref-all`
```lisp
(ref-all exp-key list [func-compare [true]])
```
Works similarly to ref, but returns a list of all index vectors found for exp-key in list.

### `rest`
```lisp
(rest list)
(rest array)
(rest str)
```
Returns all of the items in a list or a string, except for the first. rest is equivalent to cdr or tail in other Lisp dialects.

### `replace`
```lisp
(replace exp-key list exp-replacement [func-compare])
(replace exp-key list)
(replace str-key str-data exp-replacement)
(replace str-pattern str-data exp-replacement regex-option)
```
If the second argument is a list, replace replaces all elements in the list list that are equal to the expression in exp-key. The element is replaced with exp-replacement. If exp-replacement is missing, all instances of exp-key will be deleted from list.

### `reverse`
```lisp
(reverse list)
(reverse array)
(reverse string)
```
In the first and second form, reverse reverses and returns the list or array. Note that reverse is destructive and changes the original list or array.

### `rotate`
```lisp
(rotate list [int-count])
(rotate str [int-count])
```
Rotates and returns the list or string in str. A count can be optionally specified in int-count to rotate more than one position.

### `select`
```lisp
(select list list-selection)
(select list [int-index_i ... ])
(select string list-selection)
(select string [int-index_i ... ])
```
In the first two forms, select picks one or more elements from list using one or more indices specified in list-selection or the int-index_i.

### `self`
```lisp
(self [int-index ... ])
```
The function self accesses the target object of a FOOP method. One or more int-index are used to access the object members. self is set by the : colon operator.

### `set`
```lisp
(set sym-1 exp-1 [sym-2 exp-2 ... ])
```
Evaluates both arguments and then assigns the result of exp to the symbol found in sym.

### `set-ref`
```lisp
(set-ref exp-key list exp-replacement [func-compare])
```
Searches for exp-key in list and replaces the found element with exp-replacement. The list can be nested. The system variables $it contains the expression found and can be used in exp-replacement. The function returns the new modified list.

### `set-ref-all`
```lisp
(set-ref-all exp-key list exp-replacement [func-compare])
```
Searches for exp-key in list and replaces each instance of the found element with exp-replacement.

### `silent`
```lisp
(silent [exp-1 [exp-2 ... ]])
```
Evaluates one or more expressions in exp-1—. silent is similar to begin, but it suppresses console output of the return value and the following prompt.

### `slice`
```lisp
(slice list int-index [int-length])
(slice array int-index [int-length])
(slice str int-index [int-length])
```
In the first form, slice copies a sublist from a list. The original list is left unchanged.

### `sort`
```lisp
(sort list [func-compare])
(sort array [func-compare])
```
All members in list or array are sorted in ascending order. Anything may be sorted, regardless of the types.

### `starts-with`
```lisp
(starts-with str str-key [num-option])
(starts-with list [exp])
```
In the first version, starts-with checks if the string str starts with a key string in str-key and returns true or nil depending on the outcome.

### `swap`
```lisp
(swap place-1 place-2)
```
The contents of the two places place-1 and place-2 are swapped. A place can be the contents of an unquoted symbol or any list or array references expressed with nth, first, last or implicit indexing or places referenced by assoc or lookup.

### `unify`
```lisp
(unify exp-1 exp-2 [list-env])
```
Evaluates and matches exp-1 and exp-2. Expressions match if they are equal or if one of the expressions is an unbound variable (which would then be bound to the other expression).

### `unique`
```lisp
(unique list)
```
Returns a unique version of list with all duplicates removed.

### `union`
```lisp
(union list-1 list-2 [list-3 ... ])
```
union returns a unique collection list of distinct elements found in two or more lists.

### `unless`
```lisp
(unless exp-condition body)
```
The statements in body are only evaluated if exp-condition evaluates to nil or the empty list (). The result of the last expression in body is returned or the return value of exp-condition if body was not executed.

### `until`
```lisp
(until exp-condition [body])
```
Evaluates the condition in exp-condition. If the result is nil or the empty list (), the expressions in body are evaluated.

### `when`
```lisp
(when exp-condition body)
```
The statements in body are only evaluated if exp-condition evaluates to anything not nil and not the empty list (). The result of the last expression in body is returned or nil or the empty list () if body was not executed.

### `while`
```lisp
(while exp-condition body)
```
Evaluates the condition in exp-condition. If the result is not nil or the empty list (), the expressions in body are evaluated.

## String and conversion functions

### `address`
```lisp
(address int)
(address float)
(address str)
```
Returns the memory address of the integer in int, the double floating point number in float, or the string in str. This function is used for passing parameters to library functions that have been imported using the import function.

### `bigint`
```lisp
(bigint number)
(bigint string)
```
A floating point or integer number gets converted to big integer format. When converting from floating point, rounding errors occur going back and forth between decimal and binary arithmetic.

### `bits`
```lisp
(bits int [bool])
```
Transforms a number in int to a string of 1's and 0's or a list, if bool evaluates to anything not nil.

### `char`
```lisp
(char str [int-index [true]])
(char int)
```
Given a string argument, extracts the character at int-index from str, returning either the ASCII value of that character or the Unicode value on UTF-8 enabled versions of newLISP.

### `chop`
```lisp
(chop str [int-chars])
(chop list [int-elements])
```
If the first argument evaluates to a string, chop returns a copy of str with the last int-char characters omitted. If the int-char argument is absent, one character is omitted. chop does not alter str.

### `dostring`
```lisp
(dostring (sym string [exp-break]) body)
```
The expressions in body are evaluated for each character in string. The variable in sym is set to each ASCII or UTF-8 integer value of the characters before evaluation of the body expressions.

### `dup`
```lisp
(dup exp int-n [bool])
(dup exp)
```
If the expression in exp evaluates to a string, it will be replicated int-n times within a string and returned.

### `ends-with`
```lisp
(ends-with str-data str-key [num-option])
(ends-with list exp)
```
In the first syntax, ends-with tests the string in str-data to see if it ends with the string specified in str-key. It returns true or nil depending on the outcome.

### `encrypt`
```lisp
(encrypt str-source str-pad)
```
Performs a one-time pad (OTP) encryption of str-source using the encryption pad in str-pad.

### `eval-string`
```lisp
(eval-string str-source [sym-context [exp-error [int-offset]]])
```
The string in str-source is compiled into newLISP's internal format and then evaluated. The evaluation result is returned. If the string contains more than one expression, the result of the last evaluation is returned.

### `explode`
```lisp
(explode str [int-chunk [bool]])
(explode list [int-chunk [bool]])
```
In the first syntax, explode transforms the string (str) into a list of single-character strings.

### `extend`
```lisp
(extend list-1 [list-2 ... ])
(extend string-1 [string-2 ... ])
```
The list in list-1 is extended by appending list-2. More than one list may be appended.

### `find`
```lisp
(find exp-key list [func-compare | regex-option])
(find str-key str-data [regex-option [int-offset]])
```
If the second argument evaluates to a list, then find returns the index position (offset) of the element derived from evaluating exp-key.

### `find-all`
```lisp
(find-all str-regex-pattern str-text [exp [regex-option]])
(find-all list-match-pattern list [exp])
(find-all exp-key list [exp [func-compare]])
```
In the first syntax, find-all finds all occurrences of str-regex-pattern in the text str-text, returning a list containing all matching strings.

### `first`
```lisp
(first list)
(first array)
(first str)
```
Returns the first element of a list or the first character of a string. The operand is not changed. This function is equivalent to car or head in other Lisp dialects.

### `float`
```lisp
(float exp [exp-default])
```
If the expression in exp evaluates to a number or a string, the argument is converted to a float and returned.

### `format`
```lisp
(format str-format exp-data-1 [exp-data-2 ... ])
(format str-format list-data)
```
Constructs a formatted string from exp-data-1 using the format specified in the evaluation of str-format.

### `get-char`
```lisp
(get-char int-address)
```
Gets an 8-bit character from an address specified in int-address. This function is useful when using imported shared library functions with import.

### `get-float`
```lisp
(get-float int-address)
```
Gets a 64-bit double float from an address specified in int-address. This function is helpful when using imported shared library functions (with import) that return an address pointer to a double float or a pointer to a structure containing double floats.

### `get-int`
```lisp
(get-int int-address)
```
Gets a 32-bit integer from the address specified in int-address. This function is handy when using imported shared library functions with import, a function returning an address pointer to an integer, or a pointer to a structure containing integers.

### `get-long`
```lisp
(get-long int-address)
```
Gets a 64-bit integer from the address specified in int-address. This function is handy when using import to import shared library functions, a function returning an address pointer to a long integer, or a pointer to a structure containing long integers.

### `get-string`
```lisp
(get-string int-address [int-bytes [str-limit])
```
Copies a character string from the address specified in int-address. This function is helpful when using imported shared library functions with import and a C-function returns the address to a memory buffer.

### `int`
```lisp
(int exp [exp-default [int-base]])
```
If the expression in exp evaluates to a number or a string, the result is converted to an integer and returned.

### `join`
```lisp
(join list-of-strings [str-joint [bool-trail-joint]])
```
Concatenates the given list of strings in list-of-strings. If str-joint is present, it is inserted between each string in the join. If bool-trail-joint is true then a joint string is also appended to the last string.

### `last`
```lisp
(last list)
(last array)
(last str)
```
Returns the last element of a list or a string.

### `lower-case`
```lisp
(lower-case str)
```
Converts the characters of the string in str to lowercase. A new string is created, and the original is left unaltered.

### `member`
```lisp
(member exp list)
(member str-key str [num-option])
```
In the first syntax, member searches for the element exp in the list list. If the element is a member of the list, a new list starting with the element found and the rest of the original list is constructed and returned.

### `name`
This function is deprecated, use term instead.

### `nth`
```lisp
(nth int-index list)
(nth int-index array)
(nth int-index str)
(nth list-indices list)
(nth list-indices array)
```
In the first syntax group nth uses int-index an index into the list, array or str found and returning the element found at that index. See also Indexing elements of strings and lists.

### `pack`
```lisp
(pack str-format [exp-1 [exp-2 ... ]])
(pack str-format [list])
(pack struct [exp-1 [exp-2 ... ]])
(pack struct [list])
```
When the first parameter is a string, pack packs one or more expressions (exp-1 to exp-n) into a binary format specified in the format string str-format, and returning the binary structure in a string buffer.

### `parse`
```lisp
(parse str-data [str-break [regex-option]])
```
Breaks the string that results from evaluating str-data into string tokens, which are then returned in a list.

### `pop`
```lisp
(pop list [int-index-1 [int-index-2 ... ]])
(pop list [list-indexes])
(pop str [int-index [int-length]])
```
Using pop, elements can be removed from lists and characters from strings.

### `push`
```lisp
(push exp list [int-index-1 [int-index-2 ... ]])
(push exp list [list-indexes])
(push str-1 str-2 [int-index])
```
Inserts the value of exp into the list list. If int-index is present, the element is inserted at that index.

### `regex`
```lisp
(regex str-pattern str-text [regex-option [int-offset]])
```
Performs a Perl Compatible Regular Expression (PCRE) search on str-text with the pattern specified in str-pattern.

### `regex-comp`
```lisp
(regex-comp str-pattern [int-option])
```
newLISP automatically compiles regular expression patterns and caches the last compilation to speed up repetitive pattern searches.

### `replace`
```lisp
(replace exp-key list exp-replacement [func-compare])
(replace exp-key list)
(replace str-key str-data exp-replacement)
(replace str-pattern str-data exp-replacement regex-option)
```
If the second argument is a list, replace replaces all elements in the list list that are equal to the expression in exp-key. The element is replaced with exp-replacement. If exp-replacement is missing, all instances of exp-key will be deleted from list.

### `rest`
```lisp
(rest list)
(rest array)
(rest str)
```
Returns all of the items in a list or a string, except for the first. rest is equivalent to cdr or tail in other Lisp dialects.

### `reverse`
```lisp
(reverse list)
(reverse array)
(reverse string)
```
In the first and second form, reverse reverses and returns the list or array. Note that reverse is destructive and changes the original list or array.

### `rotate`
```lisp
(rotate list [int-count])
(rotate str [int-count])
```
Rotates and returns the list or string in str. A count can be optionally specified in int-count to rotate more than one position.

### `select`
```lisp
(select list list-selection)
(select list [int-index_i ... ])
(select string list-selection)
(select string [int-index_i ... ])
```
In the first two forms, select picks one or more elements from list using one or more indices specified in list-selection or the int-index_i.

### `slice`
```lisp
(slice list int-index [int-length])
(slice array int-index [int-length])
(slice str int-index [int-length])
```
In the first form, slice copies a sublist from a list. The original list is left unchanged.

### `source`
```lisp
(source)
(source sym-1 [sym-2 ... ])
```
Works almost identically to save, except symbols and contexts get serialized to a string instead of being written to a file.

### `starts-with`
```lisp
(starts-with str str-key [num-option])
(starts-with list [exp])
```
In the first version, starts-with checks if the string str starts with a key string in str-key and returns true or nil depending on the outcome.

### `string`
```lisp
(string exp-1 [exp-2 ... ])
```
Translates into a string anything that results from evaluating exp-1—. If more than one expression is specified, the resulting strings are concatenated.

### `sym`
```lisp
(sym string [sym-context [nil-flag]])
(sym number [sym-context [nil-flag]])
(sym symbol [sym-context [nil-flag]])
```
Translates the first argument in string, number, or symbol into a symbol and returns it.

### `title-case`
```lisp
(title-case str [bool])
```
Returns a copy of the string in str with the first character converted to uppercase. When the optional bool parameter evaluates to any value other than nil, the rest of the string is converted to lowercase.

### `trim`
```lisp
(trim str)
(trim str str-char)
(trim str str-left-char str-right-char)
```
Using the first syntax, all white-space characters are trimmed from both sides of str.

### `unicode`
```lisp
(unicode str-utf8)
```
Converts ASCII/UTF-8 character strings in str to UCS-4–encoded Unicode of 4-byte integers per character. The string is terminated with a 4-byte integer 0. This function is only available on UTF-8–enabled versions of newLISP.

### `utf8`
```lisp
(utf8 str-unicode)
```
Converts a UCS-4, 4-byte, Unicode-encoded string (str) into UTF-8. This function is only available on UTF-8–enabled versions of newLISP.

### `utf8len`
```lisp
(utf8len str)
```
Returns the number of characters in a UTF-8–encoded string. UTF-8 characters can be encoded in more than one 8-bit byte. utf8len returns the number of UTF-8 characters in a string. This function is only available on UTF-8–enabled versions of newLISP.

### `unpack`
```lisp
(unpack str-format str-addr-packed)
(unpack str-format num-addr-packed)
(unpack struct num-addr-packed)
(unpack struct str-addr-packed)
```
When the first parameter is a string, unpack unpacks a binary structure in str-addr-packed or pointed to by num-addr-packed into newLISP variables using the format in str-format.

### `upper-case`
```lisp
(upper-case str)
```
Returns a copy of the string in str converted to uppercase. International characters are converted correctly.

## Floating point math and special functions

### `abs`
```lisp
(abs num)
```
Returns the absolute value of the number in num.

### `acos`
```lisp
(acos num-radians)
```
The arc-cosine function is calculated from the number in num-radians.

### `acosh`
```lisp
(acosh num-radians)
```
Calculates the inverse hyperbolic cosine of num-radians, the value whose hyperbolic cosine is num-radians. If num-radians is less than 1, acosh returns NaN.

### `add`
```lisp
(add num-1 [num-2 ... ])
```
All of the numbers in num-1, num-2, and on are summed. add accepts float or integer operands, but it always returns a floating point number. Any floating point calculation with NaN also returns NaN.

### `array`
```lisp
(array int-n1 [int-n2 ... ] [list-init])
```
Creates an array with int-n1 elements, optionally initializing it with the contents of list-init. Up to sixteen dimensions may be specified for multidimensional arrays.

### `array-list`
```lisp
(array-list array)
```
Returns a list conversion from array, leaving the original array unchanged:

### `asin`
```lisp
(asin num-radians)
```
Calculates the arcsine function from the number in num-radians and returns the result.

### `asinh`
```lisp
(asinh num-radians)
```
Calculates the inverse hyperbolic sine of num-radians, the value whose hyperbolic sine is num-radians.

### `atan`
```lisp
(atan num-radians)
```
The arctangent of num-radians is calculated and returned.

### `atanh`
```lisp
(atanh num-radians)
```
Calculates the inverse hyperbolic tangent of num-radians, the value whose hyperbolic tangent is num-radians. If the absolute value of num-radians is greater than 1, atanh returns NaN; if it is equal to 1, atanh returns infinity.

### `atan2`
```lisp
(atan2 num-Y-radians num-X-radians)
```
The atan2 function computes the principal value of the arctangent of Y / X in radians. It uses the signs of both arguments to determine the quadrant of the return value. atan2 is useful for converting Cartesian coordinates into polar coordinates.

### `beta`
```lisp
(beta cum-a num-b)
```
The Beta function, beta, is derived from the log Gamma gammaln function as follows:

### `betai`
```lisp
(betai num-x num-a num-b)
```
The Incomplete Beta function, betai, equals the cumulative probability of the Beta distribution, betai, at x in num-x. The cumulative binomial distribution is defined as the probability of an event, pev, with probability p to occur k or more times in N trials:

### `binomial`
```lisp
(binomial int-n int-k float-p)
```
The binomial distribution function is defined as the probability for an event to occur int-k times in int-n trials if that event has a probability of float-p and all trials are independent of one another:

### `ceil`
```lisp
(ceil number)
```
Returns the next highest integer above number as a floating point.

### `cos`
```lisp
(cos num-radians)
```
Calculates the cosine of num-radians and returns the result.

### `cosh`
```lisp
(cosh num-radians)
```
Calculates the hyperbolic cosine of num-radians. The hyperbolic cosine is defined mathematically as: (exp (x) + exp (-x)) / 2. An overflow to inf may occur if num-radians is too large.

### `crc32`
```lisp
(crc32 str-data)
```
Calculates a running 32-bit CRC (Circular Redundancy Check) sum from the buffer in str-data, starting with a CRC of 0xffffffff for the first byte. crc32 uses an algorithm published by www.w3.org.

### `dec`
```lisp
(dec place [num])
```
The number in place is decremented by 1.0 or the optional number num and returned. dec performs float arithmetic and converts integer numbers passed into floating point type.

### `div`
```lisp
(div num-1 num-2 [num-3 ... ])
(div num-1)
```
Successively divides num-1 by the number in num-2—. div can perform mixed-type arithmetic, but it always returns floating point numbers. Any floating point calculation with NaN also returns NaN.

### `erf`
```lisp
(erf num)
```
erf calculates the error function of a number in num. The error function is defined as:

### `exp`
```lisp
(exp num)
```
The expression in num is evaluated, and the exponential function is calculated based on the result. exp is the inverse function of log.

### `factor`
```lisp
(factor int)
```
Factors the number in int into its prime components. When floating point numbers are passed, they are truncated to their integer part first.

### `fft`
```lisp
(fft list-num)
```
Calculates the discrete Fourier transform on the list of complex numbers in list-num using the FFT method (Fast Fourier Transform).

### `floor`
```lisp
(floor number)
```
Returns the next lowest integer below number as a floating point.

### `flt`
```lisp
(flt number)
```
Converts number to a 32-bit float represented by an integer. This function is used when passing 32-bit floats to library routines. newLISP floating point numbers are 64-bit and are passed as 64-bit floats when calling imported C library routines.

### `gammai`
```lisp
(gammai num-a num-b)
```
Calculates the incomplete Gamma function of values a and b in num-a and num-b, respectively.

### `gammaln`
```lisp
(gammaln num-x)
```
Calculates the log Gamma function of the value x in num-x.

### `gcd`
```lisp
(gcd int-1 [int-2 ... ])
```
Calculates the greatest common divisor of a group of integers. The greatest common divisor of two integers that are not both zero is the largest integer that divides both numbers.

### `ifft`
```lisp
(ifft list-num)
```
Calculates the inverse discrete Fourier transform on a list of complex numbers in list-num using the FFT method (Fast Fourier Transform).

### `inc`
```lisp
(inc place [num])
```
Increments the number in place by 1.0 or by the optional number num and returns the result. inc performs float arithmetic and converts integer numbers passed into floating point type.

### `inf?`
```lisp
(inf? float)
```
If the value in float is infinite the function returns true else nil.

### `log`
```lisp
(log num)
(log num num-base)
```
In the first syntax, the expression in num is evaluated and the natural logarithmic function is calculated from the result.

### `min`
```lisp
(min num-1 [num-2 ... ])
```
Evaluates the expressions num-1— and returns the smallest number.

### `max`
```lisp
(max num-1 [num-2 ... ])
```
Evaluates the expressions num-1— and returns the largest number.

### `mod`
```lisp
(mod num-1 num-2 [num-3 ... ])
(mod num-1)
```
Calculates the modular value of the numbers in num-1 and num-2. mod computes the remainder from the division of the numerator num-i by the denominator num-i + 1.

### `mul`
```lisp
(mul num-1 num-2 [num-3 ... ])
```
Evaluates all expressions num-1—, calculating and returning the product. mul can perform mixed-type arithmetic, but it always returns floating point numbers. Any floating point calculation with NaN also returns NaN.

### `NaN?`
```lisp
(NaN? float)
```
Tests if the result of a floating point math operation is a NaN. Certain floating point operations return a special IEEE 754 number format called a NaN for 'Not a Number'.

### `pow`
```lisp
(pow num-1 num-2 [num-3 ... ])
(pow num-1)
```
Calculates num-1 to the power of num-2 and so forth.

### `round`
```lisp
(round number [int-digits])
```
Rounds the number in number to the number of digits given in int-digits. When decimals are being rounded, int-digits is negative. It is positive when the integer part of a number is being rounded.

### `sequence`
```lisp
(sequence num-start num-end [num-step])
```
Generates a sequence of numbers from num-start to num-end with an optional step size of num-step.

### `series`
```lisp
(series num-start num-factor num-count)
(series exp-start func num-count)
```
In the first syntax, series creates a geometric sequence with num-count elements starting with the element in num-start. Each subsequent element is multiplied by num-factor. The generated numbers are always floating point numbers.

### `sgn`
```lisp
(sgn num)
(sgn num exp-1 [exp-2 [exp-3]])
```
In the first syntax, the sgn function is a logical function that extracts the sign of a real number according to the following rules:

### `sin`
```lisp
(sin num-radians)
```
Calculates the sine function from num-radians and returns the result.

### `sinh`
```lisp
(sinh num-radians)
```
Calculates the hyperbolic sine of num-radians. The hyperbolic sine is defined mathematically as: (exp (x) - exp (-x)) / 2. An overflow to inf may occur if num-radians is too large.

### `sqrt`
```lisp
(sqrt num)
```
Calculates the square root from the expression in num and returns the result.

### `ssq`
```lisp
(ssq list-vector | array-vector)
```
Calculates the sum of squares of numbers in a vector in list-vector or array-vector.

### `sub`
```lisp
(sub num-1 [num-2 ... ])
```
Successively subtracts the expressions in num-1, num-2—. sub performs mixed-type arithmetic and handles integers or floating points, but it will always return a floating point number.

### `tan`
```lisp
(tan num-radians)
```
Calculates the tangent function from num-radians and returns the result.

### `tanh`
```lisp
(tanh num-radians)
```
Calculates the hyperbolic tangent of num-radians. The hyperbolic tangent is defined mathematically as: sinh (x) / cosh (x).

### `uuid`
```lisp
(uuid [str-node])
```
Constructs and returns a UUID (Universally Unique IDentifier). Without a node spec in str-node, a type 4 UUID random generated byte number is returned.

## Matrix functions

### `det`
```lisp
(det matrix [float-pivot])
```
Returns the determinant of a square matrix. A matrix can either be a nested list or an array.

### `invert`
```lisp
(invert matrix [float-pivot])
```
Returns the inversion of a two-dimensional matrix in matrix. The matrix must be square, with the same number of rows and columns, and non-singular (invertible).

### `mat`
```lisp
(mat + | - | * | / matrix-A matrix-B)
(mat + | - | * | / matrix-A number)
```
Using the first syntax, this function performs fast floating point scalar operations on two-dimensional matrices in matrix-A or matrix-B.

### `multiply`
```lisp
(multiply matrix-A matrix-B)
```
Returns the matrix multiplication of matrices in matrix-A and matrix-B. If matrix-A has the dimensions n by m and matrix-B the dimensions k by l (m and k must be equal), the result is an n by l matrix.

### `transpose`
```lisp
(transpose matrix)
```
Transposes a matrix by reversing the rows and columns. Any kind of list-matrix can be transposed.

## Array functions

### `append`
```lisp
(append list-1 [list-2 ... ])
(append array-1 [array-2 ... ])
(append str-1 [str-2 ... ])
```
In the first form, append works with lists, appending list-1 through list-n to form a new list. The original lists are left unchanged.

### `array`
```lisp
(array int-n1 [int-n2 ... ] [list-init])
```
Creates an array with int-n1 elements, optionally initializing it with the contents of list-init. Up to sixteen dimensions may be specified for multidimensional arrays.

### `array-list`
```lisp
(array-list array)
```
Returns a list conversion from array, leaving the original array unchanged:

### `array?`
```lisp
(array? exp)
```
Checks if exp is an array:

### `det`
```lisp
(det matrix [float-pivot])
```
Returns the determinant of a square matrix. A matrix can either be a nested list or an array.

### `first`
```lisp
(first list)
(first array)
(first str)
```
Returns the first element of a list or the first character of a string. The operand is not changed. This function is equivalent to car or head in other Lisp dialects.

### `invert`
```lisp
(invert matrix [float-pivot])
```
Returns the inversion of a two-dimensional matrix in matrix. The matrix must be square, with the same number of rows and columns, and non-singular (invertible).

### `last`
```lisp
(last list)
(last array)
(last str)
```
Returns the last element of a list or a string.

### `mat`
```lisp
(mat + | - | * | / matrix-A matrix-B)
(mat + | - | * | / matrix-A number)
```
Using the first syntax, this function performs fast floating point scalar operations on two-dimensional matrices in matrix-A or matrix-B.

### `multiply`
```lisp
(multiply matrix-A matrix-B)
```
Returns the matrix multiplication of matrices in matrix-A and matrix-B. If matrix-A has the dimensions n by m and matrix-B the dimensions k by l (m and k must be equal), the result is an n by l matrix.

### `nth`
```lisp
(nth int-index list)
(nth int-index array)
(nth int-index str)
(nth list-indices list)
(nth list-indices array)
```
In the first syntax group nth uses int-index an index into the list, array or str found and returning the element found at that index. See also Indexing elements of strings and lists.

### `rest`
```lisp
(rest list)
(rest array)
(rest str)
```
Returns all of the items in a list or a string, except for the first. rest is equivalent to cdr or tail in other Lisp dialects.

### `slice`
```lisp
(slice list int-index [int-length])
(slice array int-index [int-length])
(slice str int-index [int-length])
```
In the first form, slice copies a sublist from a list. The original list is left unchanged.

### `transpose`
```lisp
(transpose matrix)
```
Transposes a matrix by reversing the rows and columns. Any kind of list-matrix can be transposed.

## Bit operators

### `<<, >>`
```lisp
(<< int-1 int-2 [int-3 ... ])
(>> int-1 int-2 [int-3 ... ])
(<< int-1)
(>> int-1)
```
The number int-1 is arithmetically shifted to the left or right by the number of bits given as int-2, then shifted by int-3 and so on.

### `&`
```lisp
(& int-1 int-2 [int-3 ... ])
```
A bitwise and operation is performed on the number in int-1 with the number in int-2, then successively with int-3, etc.

### `|`
```lisp
(| int-1 int-2 [int-3 ... ])
```
A bitwise or operation is performed on the number in int-1 with the number in int-2, then successively with int-3, etc.

### `^`
```lisp
(^ int-1 int-2 [int-3 ... ])
```
A bitwise xor operation is performed on the number in int-1 with the number in int-2, then successively with int-3, etc.

### `~`
```lisp
(~ int)
```
A bitwise not operation is performed on the number in int, reversing all of the bits.

## Predicates

### `atom?`
```lisp
(atom? exp)
```
Returns true if the value of exp is an atom, otherwise nil. An expression is an atom if it evaluates to nil, true, an integer, a float, a string, a symbol or a primitive. Lists, lambda or lambda-macro expressions, and quoted expressions are not atoms.

### `array?`
```lisp
(array? exp)
```
Checks if exp is an array:

### `bigint?`
```lisp
(bigint? number)
```
Check if a number is formatted as a big integer.

### `context?`
```lisp
(context? exp)
(context? exp str-sym)
```
In the first syntax, context? is a predicate that returns true only if exp evaluates to a context; otherwise, it returns nil.

### `directory?`
```lisp
(directory? str-path)
```
Checks if str-path is a directory. Returns true or nil depending on the outcome.

### `empty?`
```lisp
(empty? exp)
(empty? str)
```
exp is tested for an empty list (or str for an empty string). Depending on whether the argument contains elements, true or nil is returned.

### `even?`
```lisp
(even? int-number)
```
Checks if an integer number is even divisible by 2, without remainder. When a floating point number is passed for int-number, it will be converted to an integer by cutting off its fractional part.

### `file?`
```lisp
(file? str-path-name [bool])
```
Checks for the existence of a file in str-name. Returns true if the file exists; otherwise, it returns nil.

### `float?`
```lisp
(float? exp)
```
true is returned only if exp evaluates to a floating point number; otherwise, nil is returned.

### `global?`
```lisp
(global? sym)
```
Checks if symbol in sym is global. Built-in functions, context symbols, and all symbols made global using the function global are global:

### `inf?`
```lisp
(inf? float)
```
If the value in float is infinite the function returns true else nil.

### `integer?`
```lisp
(integer? exp)
```
Returns true only if the value of exp is an integer; otherwise, it returns nil.

### `lambda?`
```lisp
(lambda? exp)
```
Returns true only if the value of exp is a lambda expression; otherwise, returns nil.

### `legal?`
```lisp
(legal? str)
```
The token in str is verified as a legal newLISP symbol. Non-legal symbols can be created using the sym function (e.g.

### `list?`
```lisp
(list? exp)
```
Returns true only if the value of exp is a list; otherwise returns nil. Note that lambda and lambda-macro expressions are also recognized as special instances of a list expression.

### `macro?`
```lisp
(macro? exp)
```
Returns true if exp evaluates to a lambda-macro expression. If exp evaluates to a symbol and the symbol contains a macro-expansion expression made with the macro function, true is also returned. In all other cases nil is returned.

### `NaN?`
```lisp
(NaN? float)
```
Tests if the result of a floating point math operation is a NaN. Certain floating point operations return a special IEEE 754 number format called a NaN for 'Not a Number'.

### `nil?`
```lisp
(nil? exp)
```
If the expression in exp evaluates to nil, then nil? returns true; otherwise, it returns nil.

### `null?`
```lisp
(null? exp)
```
Checks if an expression evaluates to nil, the empty list (), the empty string "", NaN (not a number), or 0 (zero), in which case it returns true.

### `number?`
```lisp
(number? exp)
```
true is returned only if exp evaluates to a floating point number or an integer; otherwise, nil is returned.

### `odd?`
```lisp
(odd? int-number)
```
Checks the parity of an integer number. If the number is not even divisible by 2, it has odd parity. When a floating point number is passed for int-number, it will be converted first to an integer by cutting off its fractional part.

### `primitive?`
```lisp
(primitive? exp)
```
Evaluates and tests if exp is a primitive symbol and returns true or nil depending on the result. All built-in functions and functions created using import are primitives.

### `protected?`
```lisp
(protected? sym)
```
Checks if a symbol in sym is protected. Protected symbols are built-in functions, context symbols, and all symbols made constant using the constant function:

### `quote?`
```lisp
(quote? exp)
```
Evaluates and tests whether exp is quoted. Returns true or nil depending on the result.

### `string?`
```lisp
(string? exp)
```
Evaluates exp and tests to see if it is a string. Returns true or nil depending on the result.

### `symbol?`
```lisp
(symbol? exp)
```
Evaluates the exp expression and returns true if the value is a symbol; otherwise, it returns nil.

### `true?`
```lisp
(true? exp)
```
If the expression in exp evaluates to anything other than nil or the empty list (), true? returns true; otherwise, it returns nil.

### `zero?`
```lisp
(zero? exp)
```
Checks the evaluation of exp to see if it equals 0 (zero).

## Date and time functions

### `date`
```lisp
(date)
(date int-secs [int-offset])
(date int-secs int-offset str-format)
```
The first syntax returns the local time zone's current date and time as a string representation. If int-secs is out of range, nil is returned.

### `date-list`
```lisp
(date-list int-seconds [int-index])
(date-list)
```
Returns a list of year, month, date, hours, minutes, seconds, day of year and day of week from a time value given in seconds after January 1st, 1970 00:00:00. The date and time values aren given as UTC, which may differ from the local timezone.

### `date-parse`
```lisp
(date-parse str-date str-format)
```
Parses a date from a text string in str-date using a format as defined in str-format, which uses the same formatting rules found in date.

### `date-value`
```lisp
(date-value int-year int-month int-day [int-hour int-min int-sec])
(date-value list-date-time)
(date-value)
```
In the first syntax, date-value returns the time in seconds since 1970-1-1 00:00:00 for a given date and time.

### `now`
```lisp
(now [int-minutes-offset [int-index]])
```
Returns information about the current date and time as a list of integers. An optional time-zone offset can be specified in minutes in int-minutes-offset.

### `time`
```lisp
(time exp [int-count)
```
Evaluates the expression in exp and returns the time spent on evaluation in floating point milliseconds. Depending on the platform decimals of milliseconds are shown or not shown.

### `time-of-day`
```lisp
(time-of-day)
```
Returns the time in milliseconds since the start of the current day.

## Statistics, simulation and modeling functions

### `amb`
```lisp
(amb exp-1 [exp-2 ... ])
```
One of the expressions exp-1 ... n is selected at random, and the evaluation result is returned.

### `bayes-query`
```lisp
(bayes-query list-L context-D [bool-chain [bool-probs]])
```
Takes a list of tokens (list-L) and a trained dictionary (context-D) and returns a list of the combined probabilities of the tokens in one category (A or Mc) versus a category (B) or against all other categories (Mi).

### `bayes-train`
```lisp
(bayes-train list-M1 [list-M2 ... ] sym-context-D)
```
Takes one or more lists of tokens (M1, M2—) from a joint set of tokens. In newLISP, tokens can be symbols or strings (other data types are ignored).

### `corr`
```lisp
(corr list-vector-X list-vector-Y)
```
Calculates the Pearson product-moment correlation coefficient as a measure of the linear relationship between the two variables in list-vector-X and list-vector-Y. Both lists must be of same length.

### `crit-chi2`
```lisp
(crit-chi2 num-probability int-df)
```
Calculates the critical minimum Chi² for a given confidence probability num-probability under the null hypothesis and the degrees of freedom in int-df for testing the significance of a statistical null hypothesis.

### `crit-f`
```lisp
(crit-f num-probability int-df1 int-df2)
```
Calculates the critical minimum F for a given confidence probability num-probability under the null hypothesis and the degrees of freedom given in int-df1 and int-df2 for testing the significance of a statistical null hypothesis using the F-test.

### `crit-t`
```lisp
(crit-t num-probability int-df)
```
Calculates the critical minimum Student's t for a given confidence probability num-probability under the null hypothesis and the degrees of freedom in int-df for testing the significance of a statistical null hypothesis.

### `crit-z`
```lisp
(crit-z num-probability)
```
Calculates the critical normal distributed Z value of a given cumulated probability num-probability for testing of statistical significance and confidence intervals.

### `kmeans-query`
```lisp
(kmeans-query list-data matrix-centroids)
(kmeans-query list-data matrix-data)
```
In the first usage, kmeans-query calculates the Euclidian distances from the data vector given in list-data to the centroids given in matrix-centroids.

### `kmeans-train`
```lisp
(kmeans-train matrix-data int-k context [matrix-centroids])
```
The function performs Kmeans cluster analysis on matrix-data. All n data records in matrix-data are partitioned into a number of int-k different groups.

### `normal`
```lisp
(normal float-mean float-stdev int-n)
(normal float-mean float-stdev)
```
In the first form, normal returns a list of length int-n of random, continuously distributed floating point numbers with a mean of float-mean and a standard deviation of float-stdev. The random generator used internally can be seeded using the seed function.

### `prob-chi2`
```lisp
(prob-chi2 num-chi2 int-df)
```
Returns the probability of an observed Chi² statistic in num-chi2 with num-df degrees of freedom to be equal or greater under the null hypothesis. prob-chi2 is derived from the incomplete Gamma function gammai.

### `prob-f`
```lisp
(prob-f num-f int-df1 int-df2)
```
Returns the probability of an observed F statistic in num-f with int-df1 and int-df2 degrees of freedom to be equal or greater under the null hypothesis.

### `prob-t`
```lisp
(prob-t num-t int-df1)
```
Returns the probability of an observed Student's t statistic in num-t with int-df degrees of freedom to be equal or greater under the null hypothesis.

### `prob-z`
```lisp
(prob-z num-z)
```
Returns the probability of num-z, not to exceed the observed value where num-z is a normal distributed value with a mean of 0.0 and a standard deviation of 1.0.

### `rand`
```lisp
(rand int-range [int-N])
```
Evaluates the expression in int-range and generates a random number in the range of 0 (zero) to (int-range - 1).

### `random`
```lisp
(random float-offset float-scale int-n)
(random float-offset float-scale)
```
In the first form, random returns a list of int-n evenly distributed floating point numbers scaled (multiplied) by float-scale, with an added offset of float-offset. The starting point of the internal random generator can be seeded using seed.

### `randomize`
```lisp
(randomize list [bool])
```
Rearranges the order of elements in list into a random order.

### `seed`
```lisp
(seed int-seed)
(seed int-seed true [int-pre-N])
(seed)
```
Seeds the internal random generator that generates numbers for amb, normal, rand, and random with the number specified in int-seed.

### `stats`
```lisp
(stats list-vector)
```
The functions calculates statistical values of central tendency and distribution moments of values in list-vector. The following values are returned by stats in a list:

### `t-test`
```lisp
(t-test list-vector number-value)
(t-test list-vector-A list-vector-B [true])
(t-test list-vector-A list-vector-B float-probability)
```
In the first syntax the function uses a one sample Student's t test to compare the mean value of list-vector to the value in number-value:

## Pattern matching

### `ends-with`
```lisp
(ends-with str-data str-key [num-option])
(ends-with list exp)
```
In the first syntax, ends-with tests the string in str-data to see if it ends with the string specified in str-key. It returns true or nil depending on the outcome.

### `find`
```lisp
(find exp-key list [func-compare | regex-option])
(find str-key str-data [regex-option [int-offset]])
```
If the second argument evaluates to a list, then find returns the index position (offset) of the element derived from evaluating exp-key.

### `find-all`
```lisp
(find-all str-regex-pattern str-text [exp [regex-option]])
(find-all list-match-pattern list [exp])
(find-all exp-key list [exp [func-compare]])
```
In the first syntax, find-all finds all occurrences of str-regex-pattern in the text str-text, returning a list containing all matching strings.

### `match`
```lisp
(match list-pattern list-match [bool])
```
The pattern in list-pattern is matched against the list in list-match, and the matching expressions are returned in a list. The three wildcard characters ?, +, and * can be used in list-pattern.

### `parse`
```lisp
(parse str-data [str-break [regex-option]])
```
Breaks the string that results from evaluating str-data into string tokens, which are then returned in a list.

### `ref`
```lisp
(ref exp-key list [func-compare [true]])
```
ref searches for the key expression exp-key in list and returns a list of integer indices or an empty list if exp-key cannot be found. ref can work together with push and pop, both of which can also take lists of indices.

### `ref-all`
```lisp
(ref-all exp-key list [func-compare [true]])
```
Works similarly to ref, but returns a list of all index vectors found for exp-key in list.

### `regex`
```lisp
(regex str-pattern str-text [regex-option [int-offset]])
```
Performs a Perl Compatible Regular Expression (PCRE) search on str-text with the pattern specified in str-pattern.

### `regex-comp`
```lisp
(regex-comp str-pattern [int-option])
```
newLISP automatically compiles regular expression patterns and caches the last compilation to speed up repetitive pattern searches.

### `replace`
```lisp
(replace exp-key list exp-replacement [func-compare])
(replace exp-key list)
(replace str-key str-data exp-replacement)
(replace str-pattern str-data exp-replacement regex-option)
```
If the second argument is a list, replace replaces all elements in the list list that are equal to the expression in exp-key. The element is replaced with exp-replacement. If exp-replacement is missing, all instances of exp-key will be deleted from list.

### `search`
```lisp
(search int-file str-search [bool-flag [regex-option]])
```
Searches a file specified by its handle in int-file for a string in str-search. int-file can be obtained from a previous open file.

### `set-ref`
```lisp
(set-ref exp-key list exp-replacement [func-compare])
```
Searches for exp-key in list and replaces the found element with exp-replacement. The list can be nested. The system variables $it contains the expression found and can be used in exp-replacement. The function returns the new modified list.

### `set-ref-all`
```lisp
(set-ref-all exp-key list exp-replacement [func-compare])
```
Searches for exp-key in list and replaces each instance of the found element with exp-replacement.

### `starts-with`
```lisp
(starts-with str str-key [num-option])
(starts-with list [exp])
```
In the first version, starts-with checks if the string str starts with a key string in str-key and returns true or nil depending on the outcome.

### `unify`
```lisp
(unify exp-1 exp-2 [list-env])
```
Evaluates and matches exp-1 and exp-2. Expressions match if they are equal or if one of the expressions is an unbound variable (which would then be bound to the other expression).

## Financial math functions

### `fv`
```lisp
(fv num-rate num-nper num-pmt num-pv [int-type])
```
Calculates the future value of a loan with constant payment num-pmt and constant interest rate num-rate after num-nper period of time and a beginning principal value of num-pv.

### `irr`
```lisp
(irr list-amounts [list-times [num-guess]])
```
Calculates the internal rate of return of a cash flow per time period. The internal rate of return is the interest rate that makes the present value of a cash flow equal to 0.0 (zero).

### `nper`
```lisp
(nper num-interest num-pmt num-pv
[num-fv [int-type]])
```
Calculates the number of payments required to pay a loan of num-pv with a constant interest rate of num-interest and payment num-pmt.

### `npv`
```lisp
(npv num-interest list-values)
```
Calculates the net present value of an investment with a fixed interest rate num-interest and a series of future payments and income in list-values.

### `pmt`
Calculates the payment for a loan based on a constant interest of num-interest and constant payments over num-periods of time.

### `pv`
```lisp
(pv num-int num-nper num-pmt
[num-fv [int-type]])
```
Calculates the present value of a loan with the constant interest rate num-interest and the constant payment num-pmt after num-nper number of payments.

## Input/output and file operations

### `append-file`
```lisp
(append-file str-filename str-buffer)
```
Works similarly to write-file, but the content in str-buffer is appended if the file in str-filename exists.

### `close`
```lisp
(close int-file)
```
Closes the file specified by the file handle in int-file. The handle would have been obtained from a previous open operation. If successful, close returns true; otherwise nil is returned.

### `current-line`
```lisp
(current-line)
```
Retrieves the contents of the last read-line operation. current-line's contents are also implicitly used when write-line is called without a string parameter.

### `device`
```lisp
(device [int-io-handle])
```
int-io-handle is an I/O device number, which is set to 0 (zero) for the default STD I/O pair of handles, 0 for stdin, 1 for stdout and 2 for stderr.

### `exec`
```lisp
(exec str-process)
(exec str-process [str-stdin])
```
In the first form, exec launches a process described in str-process and returns all standard output as a list of strings (one for each line in standard out (STDOUT)).

### `load`
```lisp
(load str-file-name-1 [str-file-name-2 ... ] [sym-context])
```
Loads and translates newLISP from a source file specified in one or more str-file-name and evaluates the expressions contained in the file(s).

### `open`
```lisp
(open str-path-file str-access-mode [str-option])
```
The str-path-file is a file name, and str-access-mode is a string specifying the file access mode.

### `peek`
```lisp
(peek int-handle)
```
Returns the number of bytes ready to be read on a file descriptor; otherwise, it returns nil if the file descriptor is invalid. peek can also be used to check stdin. This function is only available on Unix-like operating systems.

### `print`
```lisp
(print exp-1 [exp-2 ... ])
```
Evaluates and prints exp-1— to the current I/O device, which defaults to the console window. See the built-in function device for details on how to specify a different I/O device.

### `println`
```lisp
(println exp-1 [exp-2 ... ])
```
Evaluates and prints exp-1— to the current I/O device, which defaults to the console window.

### `read`
```lisp
(read int-file sym-buffer int-size [str-wait])
```
Reads a maximum of int-size bytes from a file specified in int-file into a buffer in sym-buffer.

### `read-char`
```lisp
(read-char [int-file])
```
Reads a byte from a file specified by the file handle in int-file or from the current I/O device - e.g.

### `read-file`
```lisp
(read-file str-file-name)
```
Reads a file in str-file-name in one swoop and returns a string buffer containing the data.

### `read-key`
```lisp
(read-key [true])
```
Reads a key from the keyboard and returns an integer value. For navigation keys, more than one read-key call must be made depending of the platform OS.

### `read-line`
```lisp
(read-line [int-file])
```
Reads from the current I/O device a string delimited by a line-feed character (ASCII 10).

### `read-utf8`
```lisp
(read-utf8 int-file)
```
Reads an UTF-8 character from a file specified by the file handle in int-file. The file handle is obtained from a previous open operation.

### `save`
```lisp
(save str-file)
(save str-file sym-1 [sym-2 ... ])
```
In the first syntax, the save function writes the contents of the newLISP workspace (in textual form) to the file str-file.

### `search`
```lisp
(search int-file str-search [bool-flag [regex-option]])
```
Searches a file specified by its handle in int-file for a string in str-search. int-file can be obtained from a previous open file.

### `seek`
```lisp
(seek int-file [int-position])
```
Sets the file pointer to the new position int-position in the file specified by int-file.The new position is expressed as an offset from the beginning of the file, 0 (zero) meaning the beginning of the file.

### `write`
```lisp
(write)
(write int-file str-buffer [int-size])
(write str str-buffer [int-size])
```
In the second syntax write writes int-size bytes from a buffer in str-buffer to a file specified in int-file, previously obtained from a file open operation.

### `write-char`
```lisp
(write-char int-file int-byte1 [int-byte2 ... ])
```
Writes a byte specified in int-byte to a file specified by the file handle in int-file. The file handle is obtained from a previous open operation. Each write-char advances the file pointer by one 8-bit byte.

### `write-file`
```lisp
(write-file str-file-name str-buffer)
```
Writes a file in str-file-name with contents in str-buffer in one swoop and returns the number of bytes written.

### `write-line`
```lisp
(write-line [int-file [str]])
(write-line str-out [str]])
```
The string in str and the line termination character(s) are written to the device specified in int-file.

## Processes and the Cilk API

### `abort`
```lisp
(abort int-pid)
(abort)
```
In the first form, abort aborts a specific child process of the current parent process giving the process id in int-pid. The process must have been started using spawn. For processes started using fork, use destroy instead.

### `destroy`
```lisp
(destroy int-pid)
(destroy int-pid int-signal)
```
Destroys a process with process id in int-pid and returns true on success or nil on failure.

### `exec`
```lisp
(exec str-process)
(exec str-process [str-stdin])
```
In the first form, exec launches a process described in str-process and returns all standard output as a list of strings (one for each line in standard out (STDOUT)).

### `fork`
```lisp
(fork exp)
```
The expression in exp is launched as a newLISP child process-thread of the platforms OS.

### `pipe`
```lisp
(pipe)
```
Creates an inter-process communications pipe and returns the read and write handles to it within a list.

### `process`
```lisp
(process str-command)
(process str-command int-pipe-in int-pipe-out [int-win-option])
(process str-command int-pipe-in int-pipe-out [int-unix-pipe-error])
```
In the first syntax, process launches a process specified in str-command and immediately returns with a process ID or nil if a process could not be created.

### `receive`
```lisp
(receive int-pid sym-message)
(receive)
```
In the first syntax, the function is used for message exchange between child processes launched with spawn and their parent process. The message received replaces the contents in sym-message.

### `semaphore`
```lisp
(semaphore)
(semaphore int-id)
(semaphore int-id int-wait)
(semaphore int-id int-signal)
(semaphore int-id 0)
```
A semaphore is an interprocess synchronization object that maintains a count between 0 (zero) and some maximum value.

### `send`
```lisp
(send int-pid exp)
(send)
```
The send function enables communication between parent and child processes started with spawn.

### `share`
```lisp
(share)
(share int-address-or-handle)
(share int-address-or-handle exp-value)
(share nil int-address)
```
Accesses shared memory for communicating between several newLISP processes. When called without arguments, share requests a page of shared memory from the operating system.

### `spawn`
```lisp
(spawn sym exp [true])
```
Launches the evaluation of exp as a child process and immediately returns. The symbol in sym is quoted and receives the result of the evaluation when the function sync is executed.

### `sync`
```lisp
(sync int-timeout [func-inlet])
(sync)
```
When int-timeout in milliseconds is specified, sync waits for child processes launched with spawn to finish.

### `wait-pid`
```lisp
(wait-pid int-pid [int-options | nil])
```
Waits for a child process specified in int-pid to end. The child process was previously started with process or fork.

## File and directory management

### `change-dir`
```lisp
(change-dir str-path)
```
Changes the current directory to be the one given in str-path. If successful, true is returned; otherwise nil is returned.

### `copy-file`
```lisp
(copy-file str-from-name str-to-name)
```
Copies a file from a path-filename given in str-from-name to a path-filename given in str-to-name. Returns true if the copy was successful or nil, if the copy was unsuccessful.

### `delete-file`
```lisp
(delete-file str-file-name)
```
Deletes a file given in str-file-name. Returns true if the file was deleted successfully.

### `directory`
```lisp
(directory [str-path])
(directory str-path str-pattern [regex-option])
```
A list of directory entry names is returned for the directory path given in str-path. On failure, nil is returned. When str-path is omitted, the list of entries in the current directory is returned.

### `file-info`
```lisp
(file-info str-name [int-index [bool-flag]])
```
Returns a list of information about the file or directory in str_name. The optional index specifies the list member to return.

### `make-dir`
```lisp
(make-dir str-dir-name [int-mode])
```
Creates a directory as specified in str-dir-name, with the optional access mode int-mode. Returns true or nil depending on the outcome. If no access mode is specified, most Unix systems default to drwxr-xr-x.

### `real-path`
```lisp
(real-path [str-path])
(real-path str-exec-name true)
```
In the first syntax real-path returns the full path from the relative file path given in str-path. If a path is not given, "." (the current directory) is assumed.

### `remove-dir`
```lisp
(remove-dir str-path)
```
Removes the directory whose path name is specified in str-path. The directory must be empty for remove-dir to succeed. Returns nil on failure.

### `rename-file`
```lisp
(rename-file str-path-old str-path-new)
```
Renames a file or directory entry given in the path name str-path-old to the name given in str-path-new. Returns nil or true depending on the operation's success.

## HTTP, JSON and XML networking API

### `base64-enc`
```lisp
(base64-enc str [bool-flag])
```
The string in str is encoded into BASE64 format. This format encodes groups of 3 * 8 = 24 input bits into 4 * 8 = 32 output bits, where each 8-bit output group represents 6 bits from the input string.

### `base64-dec`
```lisp
(base64-dec str)
```
The BASE64 string in str is decoded. Note that str is not verified to be a valid BASE64 string. The decoded string is returned.

### `delete-url`
```lisp
(delete-url str-url)
```
This function deletes the file on a remote HTTP server specified in str-url. The HTTP DELETE protocol must be enabled on the target web server, or an error message string may be returned.

### `get-url`
```lisp
(get-url str-url [str-option] [int-timeout [str-header]])
```
Reads a web page or file specified by the URL in str-url using the HTTP GET protocol.

### `json-error`
```lisp
(json-error)
```
When json-parse returns nil due to a failed JSON data translation, this function retrieves an error description and the last scan position of the parser.

### `json-parse`
```lisp
(json-parse str-json-data)
```
This function parses JSON formatted text and translates it to newLISP S-expressions.

### `post-url`
```lisp
(post-url str-url str-content [str-content-type [str-option] [int-timeout [ str-header]]])
```
Sends an HTTP POST request to the URL in str-url. POST requests are used to post information collected from web entry forms to a web site.

### `put-url`
```lisp
(put-url str-url str-content [str-option] [int-timeout [str-header]])
```
The HTTP PUT protocol is used to transfer information in str-content to a file specified in str-url.

### `xfer-event`
```lisp
(xfer-event sym-event-handler | func-event-handler)
(xfer-event nil)
```
Registers a function in symbol sym-event-handler or in lambda function func-event-handler to monitor HTTP byte transfers initiated by get-url, post-url or put-url or initiated by file functions which can take URLs like load, save, read-file, write-file and app ...

### `xml-error`
```lisp
(xml-error)
```
Returns a list of error information from the last xml-parse operation; otherwise, returns nil if no error occurred.

### `xml-parse`
```lisp
(xml-parse string-xml [int-options [sym-context [func-callback]]])
```
Parses a string containing XML 1.0 compliant, well-formed XML. xml-parse does not perform DTD validation.

### `xml-type-tags`
```lisp
(xml-type-tags [exp-text-tag exp-cdata-tag exp-comment-tag exp-element-tags])
```
Can suppress completely or replace the XML type tags "TEXT", "CDATA", "COMMENT", and "ELEMENT" with something else specified in the parameters.

## Socket TCP/IP, UDP and ICMP network API

### `net-accept`
```lisp
(net-accept int-socket)
```
Accepts a connection on a socket previously put into listening mode. Returns a newly created socket handle for receiving and sending data on this connection.

### `net-close`
```lisp
(net-close int-socket [true])
```
Closes a network socket in int-socket that was previously created by a net-connect or net-accept function. Returns true on success and nil on failure.

### `net-connect`
```lisp
(net-connect str-remote-host int-port [int-timeout-ms])
(net-connect str-remote-host int-port [str-mode [int-ttl]])
(net-connect str-file-path)
```
In the first syntax, connects to a remote host computer specified in str-remote-host and a port specified in int-port. Returns a socket handle after having connected successfully; otherwise, returns nil.

### `net-error`
```lisp
(net-error)
(net-error int-error)
```
Retrieves the last error that occurred when calling a any of the following functions: net-accept, net-connect, net-eval, net-listen, net-lookup, net-receive, net-receive-udp, net-select, net-send, net-send-udp, and net-service.

### `net-eval`
```lisp
(net-eval str-host int-port exp [int-timeout [func-handler]])
(net-eval '((str-host int-port exp) ... ) [int-timeout [func-handler]])
```
Can be used to evaluate source remotely on one or more newLISP servers. This function handles all communications necessary to connect to the remote servers, send source for evaluation, and wait and collect responses.

### `net-interface`
```lisp
(net-interface str-ip-addr)
(net-interface)
```
Sets the default local interface address to be used for network connections. If not set then network functions will default to an internal default address, except when overwritten by an optional interface address given in net-listen.

### `net-ipv`
```lisp
(net-ipv int-version)
(net-ipv)
```
Switches between IPv4 and IPv6 internet protocol versions. int-version contains either a 4 for IPv4 or a 6 for IPv6. When no parameter is given, net-ipv returns the current setting.

### `net-listen`
```lisp
(net-listen int-port [str-ip-addr [str-mode]])
(net-listen str-file-path)
```
Listens on a port specified in int-port. A call to net-listen returns immediately with a socket number, which is then used by the blocking net-accept function to wait for a connection.

### `net-local`
```lisp
(net-local int-socket)
```
Returns the IP number and port of the local computer for a connection on a specific int-socket.

### `net-lookup`
```lisp
(net-lookup str-ip-number)
(net-lookup str-hostname [bool])
```
Returns either a hostname string from str-ip-number in IP dot format or the IP number in dot format from str-hostname:

### `net-packet`
```lisp
(net-packet str-packet)
```
The function allows custom configured network packets to be sent via a raw sockets interface.

### `net-peek`
```lisp
(net-peek int-socket)
```
Returns the number of bytes ready for reading on the network socket int-socket. If an error occurs or the connection is closed, nil is returned.

### `net-peer`
```lisp
(net-peer int-socket)
```
Returns the IP number and port number of the remote computer for a connection on int-socket.

### `net-ping`
```lisp
(net-ping str-address [int-timeout [int-count bool]]])
(net-ping list-addresses [int-timeout [int-count bool]]])
```
This function is only available on Unix-based systems and must be run in superuser mode, i.e.

### `net-receive`
```lisp
(net-receive int-socket sym-buffer int-max-bytes [wait-string])
```
Receives data on the socket int-socket into a string contained in sym-buffer. sym-buffer can also be a default functor specified by a context symbol for reference passing in and out of user-defined functions.

### `net-receive-from`
```lisp
(net-receive-from int-socket int-max-size)
```
net-receive-from can be used to set up non-blocking UDP communications. The socket in int-socket must previously have been opened by either net-listen or net-connect (both using the "udp" option).

### `net-receive-udp`
```lisp
(net-receive-udp int-port int-maxsize [int-microsec [str-addr-if]])
```
Receives a User Datagram Protocol (UDP) packet on port int-port, reading int-maxsize bytes.

### `net-select`
```lisp
(net-select int-socket str-mode int-micro-seconds)
(net-select list-sockets str-mode int-micro-seconds)
```
In the first form, net-select finds out about the status of one socket specified in int-socket.

### `net-send`
```lisp
(net-send int-socket str-buffer [int-num-bytes])
```
Sends the contents of str-buffer on the connection specified by int-socket. If int-num-bytes is specified, up to int-num-bytes are sent.

### `net-send-to`
```lisp
(net-send-to str-remotehost int-remoteport str-buffer int-socket)
```
Can be used for either UDP or TCP/IP communications. The socket in int-socket must have previously been opened with a net-connect or net-listen function.

### `net-send-udp`
```lisp
(net-send-udp str-remotehost int-remoteport str-buffer [bool])
```
Sends a User Datagram Protocol (UDP) to the host specified in str-remotehost and to the port in int-remoteport. The data sent is in str-buffer.

### `net-service`
```lisp
(net-service str-service str-protocol)
(net-service int-port str-protocol)
```
In the first syntax net-service makes a lookup in the services database and returns the standard port number for this service.

### `net-sessions`
```lisp
(net-sessions)
```
Returns a list of active listening and connection sockets.

## Reflection and customization

### `command-event`
```lisp
(command-event sym-event-handler | func-event-handler)
(command-event nil)
```
Specifies a user defined function for pre-processing the newLISP command-line before it gets evaluated. This can be used to write customized interactive newLISP shells and to transform HTTP requests when running in server mode.

### `error-event`
```lisp
(error-event sym-event-handler | func-event-handler)
(error-event nil)
```
sym-event-handler contains a user-defined function for handling errors. Whenever an error occurs, the system performs a reset and executes the user-defined error handler.

### `history`
```lisp
(history [bool-params])
```
history returns a list of the call history of the enclosing function. Without the optional bool-params, a list of function symbols is returned.

### `last-error`
```lisp
(last-error)
(last-error int-error)
```
Reports the last error generated by newLISP due to syntax errors or exhaustion of some resource. For a summary of all possible errors see the chapter Error codes in the appendix.

### `macro`
```lisp
(macro (sym-name [sym-param-1 ... ]) [body-1 ... ])
```
The macro function is used to define expansion macros. The syntax of macro is identical to the syntax of define-macro.

### `ostype`
```lisp
ostype
```
ostype is a built-in system constant containing the name of the operating system newLISP is running on.

### `prefix`
```lisp
(prefix sym)
```
Returns the context of a symbol in sym:

### `prompt-event`
```lisp
(prompt-event sym-event-handler | func-event-handler)
(prompt-event nil)
```
Refines the prompt as shown in the interactive newLISP shell. The sym-event-handler or func-event-handler is either a symbol of a user-defined function or a lambda expression:

### `read-expr`
```lisp
(read-expr str-source [sym-context [exp-error [int-offset]]])
```
read-expr parses the first expressions it finds in str-source and returns the translated expression without evaluating it. An optional context in sym-context specifies a namespace for the translated expression.

### `reader-event`
```lisp
(reader-event [sym-event-handler | func-event-handler])
(reader-event nil)
```
An event handler can be specified to hook between newLISP's reader, translation and evaluation process.

### `set-locale`
```lisp
(set-locale [str-locale [int-category]])
```
Reports or switches to a different locale on your operating system or platform. When used without arguments, set-locale reports the current locale being used.

### `source`
```lisp
(source)
(source sym-1 [sym-2 ... ])
```
Works almost identically to save, except symbols and contexts get serialized to a string instead of being written to a file.

### `sys-error`
```lisp
(sys-error)
(sys-error int-error)
(sys-error 0)
```
Reports the last error generated by the underlying OS which newLISP is running on.

### `sys-info`
```lisp
(sys-info [int-idx])
```
Calling sys-info without int-idx returns a list of internal resource statistics. Ten integers report the following status:

### `term`
```lisp
(term symbol)
```
Returns as a string, the term part of a symbol without the context prefix.

## System functions

### `callback`
```lisp
(callback int-index sym-function)
(callback sym-function str-return-type [str_param_type ...])
(callback sym-function)
```
In the first simple callback syntax up to sixteen (0 to 15) callback functions for up to eight parameters can be registered with imported libraries.

### `catch`
```lisp
(catch exp)
(catch exp symbol)
```
In the first syntax, catch will return the result of the evaluation of exp or the evaluated argument of a throw executed during the evaluation of exp:

### `context`
```lisp
(context [sym-context])
(context sym-context str | sym [exp-value])
```
In the first syntax, context is used to switch to a different context namespace. Subsequent loads of newLISP source or functions like eval-string and sym will put newly created symbols and function definitions in the new context.

### `copy`
```lisp
(copy exp)
(copy int-addr [bool-flag])
```
The first syntax makes a copy from evaluating expression in exp. Some built-in functions are destructive, changing the original contents of a list, array or string they are working on. With copy their behavior can be made non-destructive.

### `debug`
```lisp
(debug func)
```
Calls trace and begins evaluating the user-defined function in func. debug is a shortcut for executing (trace true), then entering the function to be debugged.

### `delete`
```lisp
(delete symbol [bool])
(delete sym-context [bool])
```
In the first syntax deletes a symbol symbol and references to the symbol in other expressions will be changed to nil.

### `default`
```lisp
(default context)
```
Return the contents of the default functor in context.

### `env`
```lisp
(env)
(env var-str)
(env var-str value-str)
```
In the first syntax (without arguments), the operating system's environment is retrieved as an association list in which each entry is a key-value pair of environment variable and value.

### `exit`
```lisp
(exit [int])
```
Exits newLISP. An optional exit code, int, may be supplied. This code can be tested by the host operating system.

### `global`
```lisp
(global sym-1 [sym-2 ... ])
```
One or more symbols in sym-1 [sym-2 ... ] can be made globally accessible from contexts other than MAIN. The statement has to be executed in the MAIN context, and only symbols belonging to MAIN can be made global. global returns the last symbol made global.

### `import`
```lisp
(import str-lib-name str-function-name ["cdecl"])
(import str-lib-name str-function-name str-return-type [str-param-type . . .])
(import str-lib-name)
```
Imports the function specified in str-function-name from a shared library named in str-lib-name. Depending on the syntax used, string labels for return and parameter types can be specified

### `main-args`
```lisp
(main-args)
(main-args int-index)
```
main-args returns a list with several string members, one for program invocation and one for each of the command-line arguments.

### `new`
```lisp
(new context-source sym-context-target [bool])
(new context-source)
```
The context context-source is copied to sym-context-target. If the target context does not exist, a new context with the same variable names and user-defined functions as in context-source is created.

### `pretty-print`
```lisp
(pretty-print [int-length [str-tab [str-fp-format]])
```
Reformats expressions for print, save, or source and when printing in an interactive console.

### `reset`
```lisp
(reset)
(reset true)
(reset int-max-cells)
```
In the first syntax, reset returns to the top level of evaluation, switches the trace mode off, and switches to the MAIN context/namespace.

### `signal`
```lisp
(signal int-signal sym-event-handler | func-event-handler)
(signal int-signal "ignore" | "default" | "reset")
(signal int-signal)
```
Sets a user-defined handler in sym-event-handler for a signal specified in int-signal or sets to a function expression in func-event-handler.

### `sleep`
```lisp
(sleep num-milliseconds)
```
Gives up CPU time to other processes for the amount of milliseconds specified in num-milli-seconds.

### `sym`
```lisp
(sym string [sym-context [nil-flag]])
(sym number [sym-context [nil-flag]])
(sym symbol [sym-context [nil-flag]])
```
Translates the first argument in string, number, or symbol into a symbol and returns it.

### `symbols`
```lisp
(symbols [context])
```
Returns a sorted list of all symbols in the current context when called without an argument. If a context symbol is specified, symbols defined in that context are returned.

### `throw`
```lisp
(throw exp)
```
Works together with the catch function. throw forces the return of a previous catch statement and puts the exp into the result symbol of catch.

### `throw-error`
```lisp
(throw-error exp)
```
Causes a user-defined error exception with text provided by evaluating exp.

### `timer`
```lisp
(timer sym-event-handler | func-event-handler num-seconds [int-option])
(timer sym-event-handler | func-event-handler)
(timer)
```
Starts a one-shot timer firing off the Unix signal SIGALRM, SIGVTALRM, or SIGPROF after the time in seconds (specified in num-seconds) has elapsed. When the timer fires, it calls the user-defined function in sym- or func-event-handler.

### `trace`
```lisp
(trace int-device)
(trace true)
(trace nil)
(trace)
```
In the first syntax the parameter is an integer of a device like an opened file. Output is continuously written to that device. If int-device is 1 output is written to stdout.

### `trace-highlight`
```lisp
(trace-highlight str-pre str-post [str-header str-footer])
```
Sets the characters or string of characters used to enclose expressions during trace.

## Importing libraries (FFI)

### `address`
```lisp
(address int)
(address float)
(address str)
```
Returns the memory address of the integer in int, the double floating point number in float, or the string in str. This function is used for passing parameters to library functions that have been imported using the import function.

### `callback`
```lisp
(callback int-index sym-function)
(callback sym-function str-return-type [str_param_type ...])
(callback sym-function)
```
In the first simple callback syntax up to sixteen (0 to 15) callback functions for up to eight parameters can be registered with imported libraries.

### `flt`
```lisp
(flt number)
```
Converts number to a 32-bit float represented by an integer. This function is used when passing 32-bit floats to library routines. newLISP floating point numbers are 64-bit and are passed as 64-bit floats when calling imported C library routines.

### `float`
```lisp
(float exp [exp-default])
```
If the expression in exp evaluates to a number or a string, the argument is converted to a float and returned.

### `get-char`
```lisp
(get-char int-address)
```
Gets an 8-bit character from an address specified in int-address. This function is useful when using imported shared library functions with import.

### `get-float`
```lisp
(get-float int-address)
```
Gets a 64-bit double float from an address specified in int-address. This function is helpful when using imported shared library functions (with import) that return an address pointer to a double float or a pointer to a structure containing double floats.

### `get-int`
```lisp
(get-int int-address)
```
Gets a 32-bit integer from the address specified in int-address. This function is handy when using imported shared library functions with import, a function returning an address pointer to an integer, or a pointer to a structure containing integers.

### `get-long`
```lisp
(get-long int-address)
```
Gets a 64-bit integer from the address specified in int-address. This function is handy when using import to import shared library functions, a function returning an address pointer to a long integer, or a pointer to a structure containing long integers.

### `get-string`
```lisp
(get-string int-address [int-bytes [str-limit])
```
Copies a character string from the address specified in int-address. This function is helpful when using imported shared library functions with import and a C-function returns the address to a memory buffer.

### `import`
```lisp
(import str-lib-name str-function-name ["cdecl"])
(import str-lib-name str-function-name str-return-type [str-param-type . . .])
(import str-lib-name)
```
Imports the function specified in str-function-name from a shared library named in str-lib-name. Depending on the syntax used, string labels for return and parameter types can be specified

### `int`
```lisp
(int exp [exp-default [int-base]])
```
If the expression in exp evaluates to a number or a string, the result is converted to an integer and returned.

### `pack`
```lisp
(pack str-format [exp-1 [exp-2 ... ]])
(pack str-format [list])
(pack struct [exp-1 [exp-2 ... ]])
(pack struct [list])
```
When the first parameter is a string, pack packs one or more expressions (exp-1 to exp-n) into a binary format specified in the format string str-format, and returning the binary structure in a string buffer.

### `struct`
```lisp
(struct symbol [str-data-type ... ])
```
The struct function can be used to define aggregate data types for usage with the extended syntax of import, pack and unpack, available on all versions of newLISP compiled with libffi.

### `unpack`
```lisp
(unpack str-format str-addr-packed)
(unpack str-format num-addr-packed)
(unpack struct num-addr-packed)
(unpack struct str-addr-packed)
```
When the first parameter is a string, unpack unpacks a binary structure in str-addr-packed or pointed to by num-addr-packed into newLISP variables using the format in str-format.

## newLISP internals API

### `command-event`
```lisp
(command-event sym-event-handler | func-event-handler)
(command-event nil)
```
Specifies a user defined function for pre-processing the newLISP command-line before it gets evaluated. This can be used to write customized interactive newLISP shells and to transform HTTP requests when running in server mode.

### `cpymem`
```lisp
(cpymem int-from-address int-to-address int-bytes)
```
Copies int-bytes of memory from int-from-address to int-to-address. This function can be used for direct memory writing/reading or for hacking newLISP internals (e.g., type bits in newLISP cells, or building functions with binary executable code on the fly).

### `dump`
```lisp
(dump [exp])
```
Shows the binary contents of a newLISP cell. Without an argument, this function outputs a listing of all Lisp cells to the console. When exp is given, it is evaluated and the contents of a Lisp cell are returned in a list.

### `prompt-event`
```lisp
(prompt-event sym-event-handler | func-event-handler)
(prompt-event nil)
```
Refines the prompt as shown in the interactive newLISP shell. The sym-event-handler or func-event-handler is either a symbol of a user-defined function or a lambda expression:

### `read-expr`
```lisp
(read-expr str-source [sym-context [exp-error [int-offset]]])
```
read-expr parses the first expressions it finds in str-source and returns the translated expression without evaluating it. An optional context in sym-context specifies a namespace for the translated expression.

### `reader-event`
```lisp
(reader-event [sym-event-handler | func-event-handler])
(reader-event nil)
```
An event handler can be specified to hook between newLISP's reader, translation and evaluation process.

## Other built-ins

### `!`
```lisp
(! str-shell-command)
```
Executes the command in str-command by shelling out to the operating system and executing. This function returns a different value depending on the host operating system.

### `$`
```lisp
($ int-idx)
```
The functions that use regular expressions (directory, ends-with, find, find-all, parse, regex, search, starts-with and replace) all bind their results to the predefined system variables $0, $1, $2–$15 after or during the function's execution.

### `lambda`
See the description of fn, which is a shorter form of writing lambda.

### `lambda-macro`
See the description of define-macro.

### `setq setf`
```lisp
(setq place-1 exp-1 [place-2 exp-2 ... ])
```
setq and setf work alike in newLISP and set the contents of a symbol, list, array or string or of a list, array or string place reference.

