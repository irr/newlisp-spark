# newLISP Spark — VM, TCO, GC, Build & Test

Spark-specific behavior that goes beyond classic newLISP (v10.7.6s1).
Sources: `README.md`, `doc/ARCHITECTURE.md`, `src/nl-vm.c`, `src/newlisp.c`.

## Bytecode VM (automatic, transparent)

When a lambda/function is defined with `define` or applied directly, the
AST is analyzed; if it consists of **pure supported expressions**
(arithmetic, comparisons, local/global variable access, `if`/`when`/
`cond`/`begin`, `while`, `let`/`local`, `dotimes`, `and`/`or`, calls,
recursion), it is compiled to linear bytecode executed by a
computed-goto (direct-threaded) dispatch loop:

- Flat `vm_stack` (operands) + `vm_frames` (call frames) — no C-stack
  recursion during execution.
- Super-instructions: `OP_LOAD_LOCAL_0..3`, `OP_STORE_LOCAL_0..3`,
  `OP_CONST_0..2`, `OP_ADD_1`, `OP_SUB_1`, `OP_SUB_2`.
- Bytecode objects carry `BYTECODE_MAGIC` (`0xBEEC0DE0`) in `cell->aux`,
  preserving newLISP's last-element list optimization.

### Tree-walker fallback

Anything outside the pure bytecode subset **falls back transparently** to
the classic AST evaluator — 100% backward compatible. Constructs that
force fallback (from `isSpecialForm()` in `nl-vm.c`):

- `letn`, `letex`, `case`, `until`, `unless`, `if-not`
- `dolist`, `dotree`, `dostring`, `for`, `for-all`, `do-until`,
  `do-while`, `doargs`, `args`
- `filter`, `clean`, `index`, `find-all`, `collect`, `amb`
- `catch`, `throw`, `throw-error`, `setf`
- `define`, `define-macro`, `def-new`, `new`, `quote`, `expand`
- `lambda`, `fn`, `lambda-macro`, `fn-macro`, `macro`, `curry`
- `context`, `eval`, `env`, `time`, `trace`, `trace-highlight`
- any macro (fexpr) or destructive primitive call
- any call passing a **quoted local symbol** (e.g. `(spawn 'a …)`,
  `(set 'a …)`) — forces fallback so dynamic symbol binding stays correct

Practical consequence: locals/parameters of *compiled* lambdas live in VM
frame slots, not in the symbol environment. Deep dynamic-scope tricks
("callee reads caller's let-bound variable") only work reliably when one
of the frames runs in the tree-walker (e.g. passes a quoted local
symbol). Within a single compiled function, normal lexical use of
params/`let` is fully correct and fast. FOOP method dispatch (`:`,
`self`) and Cilk `spawn` semantics were specifically fixed in s1 to
preserve classic behavior.

## Tail Call Optimization

- Guaranteed **O(1) stack** for tail calls — 100,000,000 self-recursive
  steps in ~1.02 s with zero stack growth.
- `OP_TAIL_CALL_SELF` reuses the caller frame in place.
- `OP_TAIL_CALL` handles mutual/general tail calls
  (`my-even?`/`my-odd?` 10 M steps in ~167 ms).
- Tail positions propagate through `if`, `when`, `cond`, `begin`, `let`,
  `local`, `and`, `or`.

Write recursions in tail form (accumulators) to benefit:

```lisp
(define (fib n , a b)
  (let ((a 0) (b 1))
    (define (loop n a b) (if (= n 0) a (loop (- n 1) b (+ a b))))
    (loop n a b)))
```

## Generational GC

- 64 MB Gen-0 nursery with bump-pointer allocation; Cheney-style
  evacuation promotes survivors to the tenured heap; roots include symbol
  trees, context tables, runtime stacks and active VM frames.
- **Nursery is disabled by default in s1** (the tree-walker holds raw C
  pointers into Gen 0 during evaluation; moving cells mid-evaluation is
  unsafe under heavy churn). Cells come from the proven non-moving
  free-list allocator.
- Opt in for experiments: `NEWLISP_ENABLE_GEN0=1 newlisp …`

## Platforms

- x86_64 and aarch64/ARM64 (incl. NVIDIA DGX Spark). Plain `make`
  auto-detects the architecture (`makefiles/dgx_spark_utf8_ffi.mk` on
  aarch64, tuned `-mcpu=native`; `makefiles/linuxLP64_utf8.mk` on
  x86_64). UTF-8 + libffi builds.
- On ARM, FFI `char` returns are read as signed (plain `char` is unsigned
  on aarch64).

## Build, install, test (from repo root)

```bash
make                                  # auto-detect platform/arch
./configure && make                   # alternative
make -f makefiles/linuxLP64_utf8.mk   # explicit x86_64
make -f makefiles/dgx_spark_utf8_ffi.mk   # explicit aarch64

sudo make install                     # /usr/local (bin, share/newlisp, doc, man)
make install_home                     # ~/bin, ~/share
make clean && make -f makefiles/linuxLP64_lib.mk && sudo make install_lib

make test        # == ./newlisp qa/qa-dot   (396 primitives, contexts, scoping)
make check       # additional suites
make testall     # extended: Cilk, FOOP, libffi, bigint, network, pipes
make test-comma  # decimal-comma locale suite (needs de_DE.UTF-8)
```

Expected `qa-dot` ending: `>>>>> ALL FUNCTIONS FINISHED SUCCESSFUL`.

Benchmarks: `bench/fib.lsp`, `bench/loop.lsp`, `bench/tco.lsp` (+ Python
3.14 reference `bench/bench.py`); qa-bench ratio 0.73–0.76 on DGX Spark
(faster than the 2016 MacBook reference).

## Version / capability probes

```lisp
(sys-info)   ; -> (bits mem … version …) e.g. version 10706
(ostype)     ; "Linux"
```

`newlisp -v` → `newLISP Spark v.10.7.6s1 64-bit on Linux IPv4/6 UTF-8 libffi.`
