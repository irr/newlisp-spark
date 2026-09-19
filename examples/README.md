# newLISP Examples

Sample applications and scripts demonstrating newLISP features.
Run most demos directly: `newlisp <name>` (from this directory
unless stated otherwise).

## Files

| File | Description |
|------|-------------|
| `async` | demo asynchronous HTTP `get-url` requests (HTTP client lives in `modules/curl.lsp`, loaded via `(module "curl.lsp")`) |
| `callback` | demo callbacks from C into newLISP (needs `newlisp.so`, see below) |
| `client` | demo for TCP networking client |
| `env.cgi` | httpd server CGI file to show environment |
| `finger` | demo for using TCP finger port |
| `form.cgi` | demo for HTML form CGI |
| `form.html` | used by `form.cgi` |
| `httpd-conf.lsp` | configuration file for newLISP httpd mode |
| `newLISP-Excel-Import.xls` | demo how to import newLISP in MS Excel |
| `observer` | demo for forking processes |
| `opengl-demo-ffi.lsp` | OpenGL demo for extended FFI |
| `opengl-demo.lsp` | OpenGL demo for simple FFI |
| `prodcons.lsp` | demo for producer/consumer messaging |
| `query` | demo for spawning parallel processes |
| `scan` | TCP port scanner |
| `server` | demo TCP server, run before TCP client |
| `sniff` | TCP port sniffer |
| `tcltk.lsp` | Tcl/Tk graphics demo |
| `udp-client.lsp` | demo for UDP client |
| `udp-server.lsp` | demo for UDP server |
| `upload.cgi` | CGI for uploading a file (works on Apache and newLISP httpd) |
| `upload.html` | used for `upload.cgi` |
| `xmlrpc.cgi` | demo for xmlrpc CGI |

## HTTP client (`get-url` & friends)

Since newLISP Spark 10.8 the HTTP client (`get-url`, `put-url`,
`post-url`, `delete-url`) is no longer built into the interpreter —
it is implemented in pure newLISP on top of **libcurl** via the FFI in
`modules/curl.lsp`. Scripts using it (like `async` and `query` here)
load it with `(module "curl.lsp")`; the classic API is unchanged and
`https://` is now supported. The built-in HTTP *server* below is
unaffected and stays in C.

## Built-in HTTP server

newLISP can serve HTTP directly from this directory (no web server
needed). From the repository root:

```
newlisp -http -d 8080 examples/httpd-conf.lsp
```

- `-http` — HTTP server mode
- `-d <port>` — listen in daemon mode (serves many connections;
  the port follows `-d` directly, there is no `-httpd` flag).
  `-p <port>` does the same without daemon mode, serving a single
  connection
- `httpd-conf.lsp` — optional request filter rejecting illegal
  `.exe` queries

The server serves files from the current directory, so `cd examples`
first to browse the demos. Then open:

- `http://localhost:8080/` — directory listing (`index.cgi`)
- `http://localhost:8080/env.cgi` — CGI environment dump
- `http://localhost:8080/form.html` → `form.cgi` — HTML form demo
- `http://localhost:8080/upload.html` → `upload.cgi` — file upload

## Callback demo (`callback`)

`callback` imports `newlispEvalStr` / `newlispCallback` from the
newLISP shared library. The library is a separate build flavor;
build it once in the repository root:

```
make clean && make -f makefiles/linuxLP64_lib.mk
sudo make install_lib    # optional, installs to /usr/local/lib
```

The script finds the library at `../newlisp.so`, `./newlisp.so`, or
`/usr/local/lib/newlisp.so`, so it runs from anywhere in the tree:

```
newlisp examples/callback
```
