---
name: nl
description: newLISP / newLISP Spark language expertise — syntax, semantics, built-in functions, standard modules, REPL/CLI usage, and Spark VM specifics. Use when writing, reading, debugging, or explaining newLISP (.lsp) code, or running newlisp scripts.
disable-model-invocation: true
---

# newLISP Spark Language Guide

newLISP is a LISP-like, dynamically-scoped scripting language. **newLISP Spark**
(this repository, v10.8) is a modernized distribution adding a
direct-threaded bytecode VM, full tail-call optimization (TCO), and a
generational GC, while remaining 100% source-compatible with classic newLISP.

Authoritative sources available locally:

- Full manual: `doc/newlisp_manual.html` (repo) or
  `/usr/local/share/doc/newlisp/newlisp_manual.html` (installed)
- Code patterns cookbook: `doc/CodePatterns.html`
- VM/GC internals: `doc/ARCHITECTURE.md`
- Runnable demos: `examples/` (see `examples/README.md`)
- Standard modules: `modules/*.lsp` (installed to
  `/usr/local/share/newlisp/modules/`)

## Running code

```bash
newlisp                          # interactive multi-line REPL
newlisp script.lsp               # run a script
newlisp -e '(+ 1 2)'             # evaluate expression, print, exit
newlisp -http -d 8080 examples/httpd-conf.lsp   # built-in HTTP server
```

The REPL echoes the value of every top-level expression (so `println` output
appears twice: the printed text, then the returned string). Use
`newlisp -c` / piped stdin for batch-style evaluation. `exit` quits.
See [reference/cli.md](reference/cli.md) for all flags.

Quick sanity checks:

```bash
newlisp -e '(map inc (sequence 1 5))'   # -> (2 3 4 5 6)
./newlisp qa/qa-dot                     # full regression suite (from repo root)
```

## Language essentials (the parts that differ from other Lisps)

- **Syntax**: parenthesized prefix expressions. Comments: `;` or `#` to end
  of line. Strings: `"..."` (escapes), `{...}` (raw, may nest),
  and `[text]...[/text]` tags (raw, for big blocks).
- **Data types**: 64-bit integers, double floats, big integers (suffix `L`,
  via `bigint`), strings, symbols, lists, arrays, lambda lists, macro lists,
  contexts. There is **no character type** — `(char "A")` returns `65`.
  Hex literals `0xFF`, octal `0755`, scientific `1.5e-3` are supported.
- **Truth**: only `nil` and the empty list `()` are false. Unlike many Lisps,
  `0` and `""` evaluate as **true**.
- **Self-evaluating**: numbers, strings, and `lambda`/`fn` expressions evaluate
  to themselves — `(lambda (x) (+ x x))` needs no quote. Primitives also
  evaluate to themselves in most positions.
- **Quoting**: `quote` / `'`. `sym`, `context`, `define`, `set` take symbols;
  remember `(set 'x 1)` quotes the symbol, not the value.
- **Dynamic scoping** is the default: a callee sees the caller's bindings
  (parameters, `let`, `local`) until they pop. Use **contexts**
  (`(context 'Foo)`) as lexically-closed namespaces/modules to avoid capture.
  Note: in Spark, lambdas compiled to bytecode keep `let`/`local`/parameter
  bindings in VM frame slots — code relying on *deep* dynamic binding across
  separately compiled lambdas runs in the tree-walker (see
  [reference/spark.md](reference/spark.md)).
- **FOOP**: functional object-oriented programming — objects are lists whose
  first element is a context; methods are context functions dispatched with
  the colon operator `(: method obj args)` and the anaphor `(self)`.
- **Macros**: `define-macro` creates fexprs (unevaluated arguments); use
  `args` / `doargs` inside to access them, `expand`/`letex` for code
  templating.
- **Anaphora**: `$it` (last `if`/pattern-match result), `$idx` (loop index in
  `dolist`, `dotimes`…), `$0`–`$15` (regex match groups), `$args`, `$count`.
- **Implicit indexing/slicing**: lists, arrays and strings can sit in
  function position: `(mylist 2)` → third element, `(mylist -1)` → last,
  `(lst 3 1)` → nested index, `("newLISP" 3)` → `"L"`. Leading numbers
  slice: `(1 2 "hello")` → `"el"`, `(1 3 '(a b c d e))` → `(b c d)`.
- **Destructive functions** modify their list/string/place argument in place:
  `push`, `pop`, `setf`, `replace`, `sort`, `reverse`, `rotate`, `extend`,
  `++`, `--`, `inc`, `dec` (on places), etc. The manual marks them with `!`.
- **Error handling**: functions return `nil` and set `last-error` on failure;
  `throw-error` raises; `catch` + `throw` for non-local exits;
  `error-event` installs a global handler; `net-error`, `sys-error` for
  domains.
- **Exit value**: every expression returns a value; `begin` groups forms;
  the last expression's value is the return value (no explicit `return` —
  use `(catch ... (throw value))` for early exit).

## Idiomatic cheat sheet

```lisp
(define (square x) (* x x))            ; define function (auto-compiled in Spark)
(define-macro (my-when c)              ; fexpr: args arrive unevaluated,
  (if (eval c) (doargs (a) (eval a)))) ;   body result is NOT re-evaluated
(macro (my-if C A B) (if C A B))       ; read-time expansion macro
                                       ;   (template vars must be UPPER-case)
(let ((a 1) (b 2)) (+ a b))            ; parallel local bindings
(letn ((a 1) (b (+ a 1))) b)           ; sequential bindings
(local (acc) (dolist (x data) (push x acc -1)))  ; hidden loop locals
(map (fn (x) (* x x)) '(1 2 3))        ; -> (1 4 9)
(filter even? (sequence 1 10))         ; -> (2 4 6 8 10)
(set 'a 1 'b 2)
(expand '(+ a b) 'a 'b)                ; -> (+ 1 2)  (template substitution)
(new Tree 'h)                          ; context as dictionary (clone of Tree)
(h "key" 42)                           ; default functor set/get -> 42
(context 'MyMod)                       ; start a module namespace
(constant (global 'PI) 3.14159)        ; protected constant
(unless (catch (doit) 'err)            ; catch pattern
  (println "failed: " err))
(spawn 'r (heavy))                     ; Cilk-API parallel process
(sync 60000)                           ; wait up to 60s for results -> r
                                       ; NOTE: bare (sync) never waits, it
                                       ; returns the list of pending pids
```

## Loading modules

```lisp
(module "sqlite3.lsp")   ; loads $NEWLISPDIR/modules/sqlite3.lsp
(load "/path/to/file.lsp")
```

`NEWLISPDIR` defaults to `/usr/local/share/newlisp` on Linux.
Module functions live in their own context, e.g. `sql3:open`, `stat:mean`.
See [reference/modules.md](reference/modules.md) for all 20 stdlib modules.

## Reference files (load on demand)

- [reference/language.md](reference/language.md) — evaluation rules, data
  types, scoping, contexts/FOOP, macros, error handling, reader syntax.
- [reference/functions.md](reference/functions.md) — all ~370 built-in
  primitives with syntax signatures, grouped by category.
- [reference/modules.md](reference/modules.md) — standard library modules
  (sqlite3, mysql, postgres, cgi, smtp, stat, gsl, zlib, …).
- [reference/cli.md](reference/cli.md) — command-line flags, REPL behavior,
  HTTP server mode, init files, `newlispdoc`.
- [reference/spark.md](reference/spark.md) — Spark VM/TCO/GC specifics,
  compilation fallback rules, build & test commands.

## When helping with newLISP code

1. Prefer `newlisp -e '...'` to verify claims about semantics quickly.
2. Remember results echo in the REPL; use `-c` for clean script output.
3. Classic newLISP answers on the web apply, but check
   [reference/spark.md](reference/spark.md) for VM fallback edge cases
   (dynamic binding via quoted symbols, `spawn`, FOOP `self`).
4. Deep function details: consult `doc/newlisp_manual.html` anchors —
   every function `foo` has anchor `#foo` (operators: `#arithmetic`,
   `#logical`, `#bit_shift`, `#colon`, `#shell`, `#systemsymbol`).
