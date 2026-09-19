# newLISP Command Line, REPL, and Tooling

Binary: `/usr/local/bin/newlisp` (symlink to `newlisp-10.8`).
Source: `man newlisp` / `doc/newlisp-man.txt`.

## Invocation

```text
newlisp [file | url ...] [options ...] [file | url ...]
```

Options and source files are processed **in the order given** (so `-s`/`-m`
before files, `-p`/`-d` after files that define server behavior).

| Flag | Meaning |
|---|---|
| `-n` | skip loading `init.lsp` / `.init.lsp` (must be first) |
| `-h` | help (no init.lsp) |
| `-v` | version string |
| `-e <expr>` | evaluate expression, print result, exit |
| `-s <n>` | stack size (default 1024) |
| `-m <MB>` | max cell memory in megabytes |
| `-x <src> <target>` | link executable with source → standalone binary |
| `-w <dir>` | set working/web-root directory |
| `-c` | no prompts, batch/pipe mode (for net-eval, HTTP) |
| `-C` | force prompts in pipe I/O (Emacs) |
| `-l <file>` | log connections / command input |
| `-L <file>` | log all (incl. HTTP requests and output) |
| `-p <port>` | listen once on TCP, stdio redirected to the socket |
| `-d <port>` | daemon mode — keep listening after each connection |
| `-t <usec>` | connection timeout for `-p`/`-d` servers |
| `-http` | accept HTTP commands only |
| `-http-safe` | safe HTTP mode (no exec/command-event) |
| `-6` | IPv6 mode (runtime switchable with `net-ipv`) |

## Startup files

Unless `-n` is given, `init.lsp` (or `$HOME/.init.lsp`) is loaded first.
`NEWLISPDIR` is set to `/usr/local/share/newlisp` if not already in the
environment — `(module "x.lsp")` loads from `$NEWLISPDIR/modules/`.

## The REPL (Spark improvements)

- **Multi-line input is automatic**: unclosed `()`, `"…"`, `{…}` (nested)
  or `[text]…[/text]` blocks collect continuation lines until balanced,
  then evaluate.
- Empty line → fresh prompt (legacy batch mode removed). `Ctrl+C` resets
  partial input.
- Every top-level result is echoed, so `(println "x")` shows the text
  *and* the returned string. Use `-c` (or pipe stdin) to suppress prompts.
- Exit with `(exit)` or Ctrl+D.
- Command-line editing uses the built-in line editor; `(history)` shows
  previous input when built with readline support.

Quick one-liners:

```bash
newlisp -e '(+ 3 4)'                       # -> 7
newlisp -e '(sys-info)'                    # version/platform vector
newlisp script.lsp arg1 arg2               # args in (main-args)
newlisp http://example.com/script.lsp      # run remote source
```

## Built-in HTTP server

```bash
newlisp -http -d 8080 -w /var/www &
newlisp httpd-conf.lsp -http -d 8080 -l /var/log/nl.log &
```

- Serves files and `.cgi` newLISP programs from the working dir.
- An optional config file can install `(command-event (fn (s) …))` to
  rewrite/filter requests (see `examples/httpd-conf.lsp`).
- Try it from the repo: `newlisp -http -d 8080 examples/httpd-conf.lsp`,
  then browse `http://localhost:8080/`.

## TCP server / distributed eval

```bash
newlisp -c -t 3000000 -d 4711 &      # daemon, 3 s timeout
newlisp -p 1234 &                    # single-connection server
```

Connect via `telnet localhost 4711`, or from another newLISP process with
`net-eval` (`(net-eval "host" 4711 "(+ 1 2)")`).

## newlispdoc

`newlispdoc` generates HTML API docs from `;; @tag` doc-comments:

```bash
newlispdoc -s -d modules/*.lsp      # index.html + per-module pages
newlispdoc file.lsp                 # -> file.lsp.html
```

Tags: `@module`, `@description`, `@syntax`, `@param`, `@return`,
`@author`, `@version`, `@example`, `@link`. Details:
`/usr/local/share/doc/newlisp/newLISPdoc.html`, `man newlispdoc`.

## Linking standalone executables

```bash
newlisp -x myscript.lsp myapp       # myapp = interpreter + embedded source
```

## Shared library

A separate build flavor produces `newlisp.so` for embedding
(`newlispEvalStr`, `newlispCallback`):

```bash
make clean && make -f makefiles/linuxLP64_lib.mk
sudo make install_lib               # /usr/local/lib
```

See `examples/callback` for a C-callback demo.
