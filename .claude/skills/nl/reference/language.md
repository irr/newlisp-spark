# newLISP Language Semantics

Core language rules for newLISP / newLISP Spark. Distilled from
`doc/newlisp_manual.html` (sections 1–24) and verified against the
installed interpreter.

## 1. Reader syntax

| Element | Syntax | Notes |
|---|---|---|
| comment | `; comment` or `# comment` | to end of line |
| string | `"a\nb"` | C-style escapes |
| raw string | `{a "b" {c} d}` | braces may nest; no escapes |
| raw string | `[text]...[/text]` | for large blocks |
| integer | `123`, `0xFF`, `0755` | 64-bit |
| float | `1.5`, `1e-3`, `.5` | double |
| bigint | `123L` or `(bigint "…")` | arbitrary precision |
| symbol | `foo`, `Foo:bar`, `+` | case-sensitive; `:` separates context |
| list | `(1 2 3)` | heterogeneous |
| quote | `'expr` = `(quote expr)` | |
| lambda | `(lambda (x) body)` / `(fn (x) body)` | self-evaluating |

Special syntax: `nil`, `true`, `()`, numbers, strings and lambdas are
self-evaluating. Symbols are case-sensitive and may contain operator
characters (`+`, `<=`, `->` …); there is no `|…|` symbol-quoting syntax —
a token like `|weird name|` is read as two symbols.

## 2. Evaluation rules

1. `(f a b …)` — evaluate `f` to a function/lambda/primitive, evaluate
   arguments **left to right** (except fexprs/macros and special forms),
   then call.
2. `(quote x)` / `'x` returns `x` unevaluated.
3. A list used in *function position* can itself be a lambda:
   `((lambda (x) (+ x x)) 2)` → `4`. A list/array/string/integer in
   function position performs **implicit indexing** (see §6).
4. Every expression returns a value; `begin` sequences forms and returns
   the last one. No explicit `return` — use `catch`/`throw`.
5. `nil` and `()` are false; everything else (including `0` and `""`) is
   true.

## 3. Variables and binding

- `(set 'x 1)`, `(setq x 1)`, `(define x 1)` — symbol assignment.
  `setf`/`setq` also write into list/array/string *places*:
  `(setf (lst 0) 9)`.
- `constant` makes a symbol write-protected; `global` allows a symbol to be
  set outside `local` shields; `protected?` tests.
- `let`/`local`/`letn` create *dynamically scoped* locals that vanish when
  the form exits (previous bindings are restored):
  - `(let ((a 1) (b 2)) …)` — parallel init
  - `(letn ((a 1) (b (+ a 1))) …)` — sequential init
  - `(letex (a 1 b 2) '(+ a b))` — expansion-time substitution
  - `(local (a b c) …)` — declare locals init to `nil`
- Unused lambda parameters double as locals:
  `(define (f x y , tmp) …)` — symbols after `,` are locals.
- `(args)` inside a function returns leftover (unmatched) arguments.
- `define` inside a function creates *static-like* persistent locals when
  used with memoization idioms (see CodePatterns §4–5).

## 4. Dynamic scoping and contexts

- **Dynamic scope**: callee sees caller's parameter/local bindings until
  the caller returns. Classic example:
  ```lisp
  (set 'x 1)
  (define (f) x)
  (define (g x) (f))
  (g 0)   ; -> 0   (f sees g's x)
  (f)     ; -> 1
  ```
  > Spark note: bytecode-compiled lambdas keep locals in VM slots, so deep
  > dynamic capture *across compiled frames* falls back / may not observe
  > them — see `reference/spark.md`. Symbol-passing (`spawn 'x …`,
  > `(set 'x …)`) forces tree-walker fallback and keeps classic semantics.
- **Contexts** = lexically closed namespaces, also used as modules,
  dictionaries and objects:
  ```lisp
  (context 'Db)            ; switch/create namespace
  (define (open f) …)      ; Db:open
  (context MAIN)           ; switch back
  (Db:open "file")         ; call through prefix
  (context? 'Db)           ; test
  (symbols 'Db)            ; list its symbols
  ```
- **Default functor**: a context symbol whose name equals the context can
  be called like a function — the basis of dictionaries and FOOP:
  ```lisp
  (new Tree 'h)            ; h is a fresh context (dictionary)
  (h "key" 42)             ; set
  (h "key")                ; -> 42
  ```
- `(new Foo 'x)` creates a distinct copy of context `Foo` bound to `x`
  (object instantiation).

## 5. Functions and macros

- `(define (name a b) body)` → function; `name` is `(lambda (a b) body)`.
- `lambda`/`fn` self-evaluate and are first-class lists:
  `(last (fn (x) (* x x)))` → `(* x x)` — functions can be built and
  modified as data (`append`, `cons`, `setf` on parts, `expand`, `letex`).
- `define-macro`/`lambda-macro` define **fexprs**: arguments arrive
  unevaluated and the **body's result is returned as-is** (not
  re-evaluated — this differs from CL-style macros). Evaluate selectively
  with `eval`, iterate raw args with `doargs`, collect with `(args)`:
  ```lisp
  (define-macro (my-when c)
    (if (eval c) (doargs (a) (eval a))))
  (define-macro (my-setq p1 p2) (set p1 (eval p2)))
  ```
- `macro` (since 10.5.8) defines **read-time expansion macros**: the call
  pattern is rewritten while source is read. Template variables must be
  **UPPER-CASE**; fixed arity (no implicit `args`):
  ```lisp
  (macro (double X) (+ X X))
  (double 21)            ; read as (+ 21 21) -> 42
  (read-expr "(double 21)")   ; -> (+ 21 21)
  ```
- `expand` substitutes symbol *values* into a quoted template:
  `(set 'a 1 'b 2) (expand '(+ a b) 'a 'b)` → `(+ 1 2)`.
  `letex` binds names then splices into the following expression.
- `curry` partially applies: `(map (curry + 10) '(1 2))` → `(11 12)`.
- `apply` needs a list of args; `map` maps over one or more lists/arrays.
- `self` inside a function refers to the enclosing lambda (recursion and
  FOOP method access).

## 6. Lists, arrays, strings — access & mutation

- Construction: `list`, `cons`, `append`, `push`, `dup`, `sequence`,
  `series`, `collect`, `array` (fast random access, `(array-list a)`).
- Access: `first` `last` `rest` `nth` `select` `slice` `chop` `flat`
  `member` `assoc` `lookup` `ref` `ref-all`.
- **Implicit indexing**: object in function position with trailing indices:
  `(lst 0)` → first, `(lst -1)` → last, `(lst 3 1)` → nested index,
  `("newLISP" 3)` → `"L"`, `(arr 1 0)` → element. **Slicing** puts the
  numbers first: `(3 2 lst)` → 2 elements from index 3,
  `(1 2 "hello")` → `"el"`, `(-3 lst)` → last 3 elements. Indices can also
  come from a list: `(lst '(3 1))` — integrates with `ref`/`push`/`pop`
  index vectors.
- **Place references** for mutation: `(setf (lst 1) 'x)`, `(push v lst)`,
  `(push v lst -1)` (at end), `(pop lst)`, `(pop lst 2)`, `inc`/`dec`,
  `++`/`--`, `(replace …)`, `(rotate lst)`, `(sort lst)` — all destructive.
- Destructuring: `(bind '((a b) lst))`, `setf` with patterns, `unify`
  (Prolog-style unification with `?` variables).
- Association lists: `assoc`/`lookup`, `set-ref`/`set-ref-all` update in
  place, `pop-assoc` removes.
- Higher-order: `map` `filter` `clean` `index` `exists` `for-all`
  `find-all` `count` `sort` (with comparator) `unify` `unique`
  `difference` `intersect` `union` `match` (list patterns with `?`).

## 7. Control flow

```lisp
(if c a b)              ; b optional; result in $it
(when c body…) (unless c body…)
(cond (c1 b1) (c2 b2) (true else))
(case x (1 'one) (2 'two) (else 'other))
(while c body…) (until c body…) (do-while body c) (do-until body c)
(dolist (x lst) body…)        ; $idx = current index
(dotimes (i n) body…)
(for (i 1 10 [step]) body…)
(dotree (sym ctx) body…)      ; walk context symbols
(for-all pred lst) (exists pred lst)
(and a b c) (or a b c) (not x)
(catch body 'sym)             ; (throw value) exits catch with value
```
There is no `loop`/`return` — use `while`/`until` break conditions, or
`catch`+`throw` for early exit:
`(catch (dolist (x lst) (if (> x 3) (throw x))) 'r) ; r -> 4`

## 8. Error handling

- Most primitives return `nil` (or `()`) on failure and set
  `(last-error)` / `(sys-error)` / `(net-error)`.
- `(throw-error "msg")` signals a user error.
- `(error-event (fn () (println (last-error))))` — global handler.
- `catch`/`throw` for control-flow-style exits.
- `debug`, `trace`, `trace-highlight` for debugging; `timer` for repeated
  callbacks; `signal` for OS signals.

## 9. Processes and networking (overview)

- Cilk API: `(spawn 'result expr)` → async child process, returns pid;
  `(sync timeout-ms)` waits and binds results into the spawn symbols
  (bare `(sync)` does **not** wait — it returns pending pids);
  `abort` cancels. `fork`, `pipe`, `process`, `semaphore`,
  `share` (shared memory), `send`/`receive` for messaging
  (pass `true` as spawn's 3rd arg when using `send`/`receive`).
- TCP/UDP/ICMP: `net-listen` `net-accept` `net-connect` `net-send`
  `net-receive` `net-select` `net-peek` `net-eval` (distributed eval),
  `net-ping`, etc.
- HTTP client: `get-url` `post-url` `put-url` `delete-url`.
- JSON/XML: `json-parse`, `xml-parse`, `xml-type-tags`, `json-error`,
  `xml-error`.
- FFI: `import`, `struct`, `pack`/`unpack`, `callback`, `get-string`/
  `get-int`/…, `address`. Spark builds include libffi.

## 10. Useful system bits

- `(sys-info)` — version/platform vector; `(ostype)` → `"Linux"` etc.
- `(main-args)` — script command-line arguments (first is program name).
- `(env "VAR")` / `(env "VAR" value)` — environment access.
- `$0`–`$15` regex captures; `$it` anaphoric result; `$idx` loop index.
- `(exit [code])`, `(reset)` (reboot interpreter), `(symbols)` list all,
  `(source 'fn)` print definition, `(save "file.lsp" 'sym-or-ctx)`.
- Pretty printing: `pretty-print`. Tracing: `(trace true)`.
