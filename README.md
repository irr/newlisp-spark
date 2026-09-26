# newLISP Spark

<p align="center">
  <img src="images/newLISP-spark.png" alt="newLISP Spark logo" width="220">
</p>

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Regression Tests](https://img.shields.io/badge/qa--dot-100%25%20Passing-brightgreen.svg)](qa/qa-dot)
[![Tail Call Optimization](https://img.shields.io/badge/TCO-O(1)%20Stack-blueviolet.svg)](#3-tail-call-optimization-tco-and-mutual-recursion)
[![Speed vs Python](https://img.shields.io/badge/Speed%20vs%20Python%203.14-2.02x%20Faster-orange.svg)](#performance-benchmarks-newlisp-spark-vs-python-314)

**newLISP Spark** is a modernized, high-performance distribution of newLISP — an elegant, lightweight, LISP-like scripting language originally created by **Lutz Mueller** for general programming, artificial intelligence, data manipulation, and statistical computing.

This enhanced release overhauls the newLISP engine with a **Direct-Threaded Bytecode Virtual Machine**, full **Tail Call Optimization (TCO)**, achieving order-of-magnitude speedups in recursion and iterative loops — and now runs the **complete regression suite** (`make testall`) cleanly on **x86_64 and aarch64/ARM64**, including NVIDIA **DGX Spark**.

**Maintained by Ivan Rocha** — Copyright (C) 2026 Ivan Rocha.

---

## Key Enhancements

- **Direct-Threaded Bytecode Virtual Machine (`nl-vm.c`, `nl-vm.h`)**:
  - **Computed-Goto Dispatch**: Employs GCC/Clang `&&label` jump tables to eliminate branch mispredictions and loop branching overhead inherent in traditional `switch/case` interpreters.
  - **Specialized Super-Instructions**: Immediate opcode specializations (`OP_LOAD_LOCAL_0..3`, `OP_STORE_LOCAL_0..3`, `OP_CONST_0..2`, `OP_ADD_1`, `OP_SUB_1`, `OP_SUB_2`) bypass operand fetches and optimize frequent variable access and loop arithmetic.
  - **Non-Recursive Call Frame Execution**: Employs a flat frame stack (`vm_frames`) and operand stack (`vm_stack`), completely removing C call-stack recursion overhead during function evaluation.
  - **Transparent JIT/AST Fallback**: Functions and lambdas containing dynamic binding, metaprogramming, or constructs outside pure bytecode semantics fall back automatically and transparently to newLISP's classic tree-walking evaluator.

- **Full Tail Call Optimization (TCO) (`nl-vm.c`, `nl-vm.h`)**:
  - **Guaranteed $O(1)$ Stack Space**: Eliminates call stack overflow hazards for arbitrarily deep and infinite recursions by reusing execution frames in-place.
  - **Self-Tail Recursion (`OP_TAIL_CALL_SELF`)**: Directly reuses the caller's frame via zero-overhead stack argument copying and local variable clearing. Over **100,000,000 recursive steps** execute in **~1.02 seconds** with zero stack growth.
  - **Mutual & General Tail Calls (`OP_TAIL_CALL`)**: Reuses the active frame for calls to other compiled functions, enabling clean, idiomatic state machines and mutual recursion (`my-even?` / `my-odd?` 10,000,000 steps in **~167 ms**).
  - **Comprehensive Tail Position Analysis**: Automatically propagates tail positions through control-flow constructs: `if`, `when`, `cond`, `begin`, `let`, `local`, `and`, and `or`.

- **High-Throughput Generational Garbage Collector (`newlisp.c`, `newlisp.h`)**:
  - **64 MB Gen 0 Nursery**: Ultra-fast bump-pointer allocation (`cell = gen0_ptr++`) eliminates pool searching and per-cell free overhead for short-lived intermediate objects.
  - **Cheney-Style Evacuation**: Live objects surviving nursery collections are promoted (`gcEvacuate`) to the tenured Gen 1 heap.
  - **Comprehensive Root Scanning**: Traverses symbol trees, context tables, runtime stacks (`envStack`, `resultStack`, `lambdaStack`), and active VM execution frames.
  - **Safe-point collection — opt-in via `NEWLISP_ENABLE_GEN0=1`**: allocators never collect; past the arena capacity they fall back to the Gen 1 free list until a *top-level expression boundary* (`gen0MaybeCollect()` after each REPL/daemon command) collects, where the C stack provably holds no raw pointers into the nursery. Within one long-running expression the deterministic VM reclamation (below) keeps memory bounded on Gen 1. Two nursery-corrupting bugs were fixed on the way (`p_setf`/`updateCell` pushed arena cells onto the Gen 1 free list), and the full suite (qa-dot, qa-vm-mem, qa-vm-edges, qa-factorfibo incl. the 1M sieve, exception/float/FOOP/bigint/inplace) passes with the nursery enabled. `NEWLISP_GEN0_CELLS=N` overrides the arena size for testing.

- **Deterministic VM Memory Reclamation (`nl-vm.c`)** — compiled code no longer leaks:
  - **Ownership tracking**: a shadow map marks sole-owned VM temporaries (arithmetic results, argument copies) and reclaims them at every drop site — operand pops, slot overwrites, frame teardown, tail-call slot resets — with identity guards for argument-aliased values and zero-copy ownership transfer into symbols and return values.
  - **Error unwinding**: `errorProc()`/`throw` longjmps used to leak every in-flight VM temporary and frame (50k caught errors leaked ~150k cells); catch sites now unwind the VM to their captured state.
  - **Result**: loops that leaked ~2 cells/iteration (200M-iteration count-down grew RSS to ~6.5 GB) now run flat at ~510 cells; a 600-request HTTP-daemon soak stays flat at ~3.3 MB RSS; `qa-bench` improved from ratio 1.09 → 0.51. Guarded by `qa-vm-mem`/`qa-vm-edges` in `make testall`.

- **Correctness fixes found by the reclamation work**:
  - `takeEvalResult()`: mid-list boolean arguments (`(< a b)`) destroyed all parameter bindings of tree-walker lambdas (stale shared-singleton entry on the resultStack was popped as the argument-list head).
  - `swap` was missing the `SYMBOL_DESTRUCTIVE` flag: compiled lambdas corrupted the shared constant table instead of mutating source literals — `qa-inplace` passes again (had been failing since v10.8).
  - `p_address` keeps its argument cells alive for the enclosing expression (it returns the address of the argument cell's own storage).

- **Native aarch64 / ARM64 Support (e.g. NVIDIA DGX Spark)**:
  - **Auto-detecting build**: plain `make` now detects aarch64 (`uname -m`) and selects the new `makefiles/dgx_spark_utf8_ffi.mk` (64-bit UTF-8 + libffi, tuned with `-mcpu=native` for the Grace CPU); x86_64 keeps its previous makefile. No manual makefile selection needed on ARM Linux.
  - **libffi correctness on ARM**: FFI `char` returns are now read as `signed char` — plain `char` is unsigned on aarch64, which corrupted signed 8-bit FFI return values.
  - **Portable FFI test suite**: `qa-libffi` no longer hardcodes `cc -m64` — it picks the right flags per architecture, so the full FFI/struct/callback battery passes on ARM Linux.
  - **Verified on DGX Spark**: the complete extended suite (`make testall` — 21 tests incl. Cilk process API, FOOP, bigint, libffi, network, pipes) passes end-to-end, with a **0.73–0.76 qa-bench performance ratio** (vs. the 2016 MacBook reference calibration, i.e. faster than the reference machine).

- **Bytecode VM Correctness Fixes (s1)**:
  - **Cilk process API fixed** (`spawn`/`sync`/`abort`): the compiler turned `let`/`local`-bound variables into VM slots, but `spawn` writes results through the *symbol* (newLISP's dynamic binding) — spawned results were invisible to compiled code. Calls passing a quoted local symbol (e.g. `(spawn 'a ...)`, `(set 'a ...)`) now force fallback to the tree-walking evaluator, restoring correct semantics.
  - **FOOP fixed** (`:` dispatch, `self`, segfault removed): symbols merely *named* `self` are no longer miscompiled as self-recursion; VM frame entry now maintains the FOOP `objSymbol` (so `(self n)` works in compiled methods); `(: method obj ...)` compiles with the raw method-name symbol and `p_colon` accepts `(quote sym)`.
  - **Zero compiler warnings**: the build is clean under `-Wall` on aarch64 GCC (fixed `-Wunused-value`, `-Wmisleading-indentation`, `-Wunused-result`, `-Wstringop-truncation`, `-Wrestrict`, `-Wformat-truncation`/`-Wformat-overflow`, `-Walloca-larger-than`).

- **HTTP Client on libcurl via FFI (`modules/curl.lsp`, new in 10.8)**:
  - **No more C HTTP client**: `get-url`, `put-url`, `post-url` and `delete-url` are implemented in pure newLISP on top of **libcurl** through the libffi FFI — the legacy raw-socket C client was removed from `nl-web.c`.
  - **Drop-in compatible**: same names, signatures, options (`"header"`, `"list"`, `"debug"`, `"raw"`), timeouts, custom headers, `HTTP_PROXY` support, `file://` URLs and `ERR:` message strings; `xfer-event` progress callbacks are honored. Load with `(module "curl.lsp")`.
  - **URL file I/O kept**: `read-file`, `write-file`, `append-file`, `delete-file`, `load` and `save` on `http://` URLs delegate to the module. Bonus: **`https://` now works** (the old client spoke plain HTTP only).
  - **Built-in HTTP server unchanged**: the `newlisp -http -d PORT` server/CGI mode stays in C.

- **Memory Safety & Rock-Solid Compatibility**:
  - **Magic-Tagged Bytecode Handles**: Bytecode objects are tagged with `BYTECODE_MAGIC` (`0xBEEC0DE0`) in `cell->aux`, preserving newLISP's native last-element pointer optimization on standard lists and eliminating memory corruption hazards.
  - **100% Test Suite Pass**: All 374 built-in primitives, contexts as objects, and scoping tests in the `qa-dot` suite pass with **0 errors** — and the complete extended suite (`make testall`, 21 tests incl. Cilk/FOOP/libffi/bigint/network) passes end-to-end on x86_64 **and aarch64/ARM64 (DGX Spark)**.

- **Modernized Interactive REPL (`newlisp.c`)**:
  - **Automatic Multi-Line Input**: Automatically detects incomplete expressions (unclosed parentheses `(...)`, double-quoted strings `"..."`, `{...}` braced strings with nesting, and `[text]...[/text]` tags) and seamlessly collects continuation lines until brackets are balanced, then evaluates immediately.
  - **Clean Line & Interrupt Handling**: Hitting `[Enter]` on an empty line returns a fresh prompt instead of entering legacy batch mode. `Ctrl+C` cleanly resets partial input buffers, and multi-line code can be piped directly from scripts/stdin without syntax errors.

---

## Building and Installation

### Prerequisites
- GCC or Clang (supporting C99/GNU extensions for computed gotos)
- GNU Make

### Build on Linux
```bash
# Automatic platform AND architecture detection
# (aarch64/ARM64 — e.g. NVIDIA DGX Spark — is auto-detected):
make

# Or configure first:
./configure
make

# Or build with a specific makefile:
make -f makefiles/linuxLP64_utf8.mk
make -f makefiles/dgx_spark_utf8_ffi.mk   # aarch64/ARM64 Linux (DGX Spark)
```

### Installation
```bash
# System-wide install of the binary and modules (requires root):
sudo make install          # /usr/local/bin/newlisp
                           # /usr/local/share/newlisp/modules/

# User home directory install:
make install_home          # ~/.local/bin/newlisp
                           # ~/.local/share/newlisp/modules/

# Shared library flavor (newlisp.so — for embedding and callback
# examples; separate build flavor, clean between flavors):
make clean && make -f makefiles/linuxLP64_lib.mk
sudo make install_lib          # installs to /usr/local/lib
```

### Try it: Built-in HTTP Server
newLISP serves HTTP directly — no web server needed (from the repo root):
```bash
newlisp -http -d 8080 examples/httpd-conf.lsp
```
Then open `http://localhost:8080/` for the CGI directory listing of the
examples. See [`examples/README.md`](examples/README.md) for details and
the callback/embedding demo.

### Try it: HTTP Client (libcurl via FFI)
The HTTP client functions live in `modules/curl.lsp` (libcurl + libffi,
no C client in the interpreter anymore):
```bash
# with the server above still running:
newlisp -e '(module "curl.lsp") (println (get-url "http://localhost:8080/" "list"))'
```
The classic API is unchanged: `(get-url url ["header|list|debug|raw"]
[timeout-ms [header]])`, likewise `put-url`, `post-url`, `delete-url`.

---

## Testing/Validation (including Regression Test)

### Running the QA Regression Suite
Verify complete language integrity across all primitive functions, scoping, and context features:
```bash
./newlisp qa/qa-dot        # or: make test
```
Expected summary output:
```text
Testing built-in functions ...
...
Testing contexts as objects and scoping rules ...
total time: ...
>>>>> ALL FUNCTIONS FINISHED SUCCESSFUL: ./newlisp
```

Additional test suites can be executed via:
```bash
make check
# or the complete extended suite (Cilk processes, FOOP, libffi,
# bigint, network, pipes — verified green on x86_64 and aarch64/DGX Spark):
make testall
# decimal-comma locale suite (qa/qa-comma; needs de_DE.UTF-8 installed):
make test-comma
```

---

## Repository Structure

```text
.
├── src/                      # Interpreter: runtime & GenGC (newlisp.c/h), bytecode VM (nl-vm.c/h), built-ins (nl-*.c)
├── pcre/                     # Bundled PCRE regular expression library (vendored)
├── makefiles/                # Build definitions for Linux (x86_64 + aarch64/DGX Spark)
├── bench/                    # Benchmark harnesses: fib.lsp, loop.lsp, tco.lsp + Python 3.14 reference (bench.py)
├── qa/                       # Test suites (run from the repository root)
│   ├── qa-dot / qa-comma     # Complete language regression test suites (`make test` / `make test-comma`)
│   └── qa-specific-tests/    # Extended suite: Cilk, FOOP, libffi, bigint, network, pipes (`make testall`)
├── modules/                  # Standard library modules (curl, crypto, sqlite3, stat, etc.)
├── examples/                 # Sample applications and scripts
└── doc/
    ├── ARCHITECTURE.md       # VM bytecode instruction set, memory layout & GC architecture
    ├── CHANGES.txt           # Version history and detailed changelog
    ├── newlisp_manual.html   # Full reference manual and language specification
    ├── MemoryManagement.html # Original ORO memory management documentation
    ├── INSTALL.txt           # Detailed platform installation instructions
    └── README-old            # Legacy newLISP README by Lutz Mueller
```

---

## Documentation Links

- [**Architecture & VM Internals**](doc/ARCHITECTURE.md) — Comprehensive technical breakdown of bytecode opcodes, computed goto dispatch, frame layout, and generational GC evacuation.
- [**Examples Index**](examples/README.md) — network/FFI/HTTP demos, built-in HTTP server usage, and the callback embedding demo.
- [**Changelog**](doc/CHANGES.txt) — Chronological record of features, fixes, and optimizations.
- [**newLISP Reference Manual**](doc/newlisp_manual.html) — Complete language manual, functions reference, and syntax guide.
- [**Original newLISP README**](doc/README-old) — Lutz Mueller's original documentation, history, and notes.

---

## License & Credits

- Copyright (C) 2026 Ivan Rocha (maintainer; aarch64/DGX Spark support, VM correctness and GC safety fixes)
- Copyright (C) 2026 KIM Taegyoon
- Copyright (C) 2020 Lutz Mueller

- **newLISP** was originally designed and implemented by **Lutz Mueller** (Nuevatec).
- **newLISP Spark** is released under the [GNU General Public License Version 3 (GPLv3)](LICENSE). See [`LICENSE`](LICENSE) or [`doc/COPYING.txt`](doc/COPYING.txt) for the complete license text.
- Documentation files are distributed under the GNU Free Documentation License (GFDL).
