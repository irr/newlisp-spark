# newLISP Standard Library Modules

21 modules ship in `modules/` (repo) and install to
`/usr/local/share/newlisp/modules/`.

Load with:

```lisp
(module "sqlite3.lsp")     ; resolves via $NEWLISPDIR/modules/
;; or absolute:
(load "/usr/local/share/newlisp/modules/sqlite3.lsp")
```

`NEWLISPDIR` defaults to `/usr/local/share/newlisp` (set at startup from
the environment if already defined). Each module wraps its API in its own
context — call functions with the prefix shown below (e.g. `sql3:open`).

Generate HTML API docs for modules with:
`newlispdoc -s -d modules/*.lsp` (see `newlispdoc -h`, man `newlispdoc`).

## Databases

### `sqlite3.lsp` — context `sql3`
SQLite3 in-process database (requires `libsqlite3.so`).
`(sql3:open "db")`, `(sql3:sql "SELECT …")` → rows as lists,
`sql3:bind-parameter` (SQL-injection-safe), `sql3:get-values`,
`sql3:colnames`, `sql3:tables`, `sql3:columns`, `sql3:changes`,
`sql3:rowid`, `sql3:error`, `sql3:close`. Built-in self-test:
`(test-sqlite3)`.

```lisp
(module "sqlite3.lsp")
(sql3:open "test.db")
(sql3:sql "CREATE TABLE t (a INTEGER, b TEXT)")
(sql3:sql "INSERT INTO t VALUES (1,'hello')")
(sql3:sql "SELECT * FROM t")   ; -> ((1 "hello"))
(sql3:close)
```

### `mysql.lsp` — context `MySQL`
MySQL 5.x client: `MySQL:connect`, `MySQL:query`, `MySQL:fetch-row`,
`MySQL:fetch-all`, `MySQL:num-rows`, `MySQL:fields`, `MySQL:escape`,
`MySQL:inserted-id`, `MySQL:close-db`.

### `postgres.lsp` — context `PgSQL`
PostgreSQL client (9.4+): `PgSQL:connect`/`PgSQL:connectdb`,
`PgSQL:query`, `PgSQL:fetch-row`/`fetch-all`/`fetch-value`,
`PgSQL:escape-literal`, `PgSQL:error`, `PgSQL:server-version`,
`PgSQL:close-db`.

### `odbc.lsp` — context `ODBC`
Generic ODBC: `ODBC:connect`, `ODBC:query`, `ODBC:fetch-row`,
`ODBC:tables`, `ODBC:columns`, `ODBC:close-db`.

## Internet / protocols

### `curl.lsp` — context `Curl` (defines `MAIN:get-url` & friends)
HTTP client on libcurl via FFI (Linux only, needs a `-DFFI` build).
Loading it defines `get-url`, `put-url`, `post-url`, `delete-url` in MAIN
(legacy drop-in replacement for the old C primitives, which were removed;
URL support in `read-file`/`write-file`/`delete-file`/`load`/`save`
delegates to these functions and requires this module to be loaded).
Classic syntax: `(get-url url ["header|list|debug|raw"] [timeout-ms [header]])`.

### `cgi.lsp` — context `CGI`
CGI helpers for GET/POST: `CGI:put-page`, `CGI:url-translate`,
`CGI:get-vars`, `CGI:set-cookie`, `CGI:get-cookie`. See `examples/*.cgi`.

### `ftp.lsp` — context `FTP`
FTP transfers: `FTP:get`, `FTP:put`, `FTP:transfer`.

### `smtp.lsp` / `smtpx.lsp` — context `SMTP`
Send mail via SMTP (`smtpx` adds attachments):
`SMTP:send-mail from to subject body [server [user pass port]]`,
`SMTP:attach-document` (smtpx).

### `pop3.lsp` — context `POP3`
Mail retrieval: `POP3:get-all-mail`, `POP3:get-new-mail`,
`POP3:get-mail-status`, `POP3:delete-old-mail`.

### `xmlrpc-client.lsp` — context `XMLRPC`
XML-RPC client: `XMLRPC:execute`, `XMLRPC:system.listMethods`,
`XMLRPC:get-struct`, `XMLRPC:get-array`.

## Math / science / data

### `stat.lsp` — context `stat`
Descriptive stats & regression on lists: `stat:sum`, `stat:mean`,
`stat:var`, `stat:sdev`, `stat:cov`, `stat:corr`, `stat:regression`,
`stat:fit`, `stat:multiple-reg`, `stat:cumulate`, `stat:smooth`,
`stat:moments`, matrix helpers (`stat:matrix`, `stat:cov-matrix`…).
(Built-ins `stats`, `corr`, `t-test`, `bayes-train`, `kmeans-train` need
no module.)

### `gsl.lsp` — context `gsl`
GNU Scientific Library bindings (requires libgsl): `gsl:SVD`,
`gsl:QRD`/`gsl:QR-solve`, `gsl:CholeskyD`/`gsl:Cholesky-solve`,
`gsl:diagonal`, list↔vector/matrix converters.

### `infix.lsp` — context `INFIX`
Infix → prefix expression translator: `(INFIX:xlate "a + b * c")`.

### `crypto.lsp` — context `crypto`
Hashing via OpenSSL libcrypto: `crypto:md5`, `crypto:sha1`,
`crypto:sha256`, `crypto:ripemd160`, `crypto:hmac`.
(Built-in `(encrypt str password)` does XOR one-time-pad.)

### `zlib.lsp` — context `zlib`
`zlib:gz-read-file`, `zlib:gz-write-file` — gzip file I/O.

## Graphics

### `canvas.lsp` — context `cv`
Generates HTML5 `<canvas>` graphics: `cv:canvas`, `cv:goto`, `cv:draw`,
`cv:bezier`, `cv:circle`, `cv:pie`, `cv:text`, `cv:render`,
`cv:show-in-browser`.

### `plot.lsp` — context `plot`
Data plotting to canvas: `plot:plot` (line), `plot:XY` (scatter),
`plot:export`, `plot:reset`.

### `postscript.lsp` — context `ps`
PostScript file generation: `ps:ps`, `ps:drawto`, `ps:circle`,
`ps:text`, `ps:render`, `ps:save`.

## System / misc

### `unix.lsp` — context `unix`
Direct libc bindings (errno, chmod, link, kill, …) — thin wrappers via
FFI `import`.

### `getopts.lsp` — context `getopts`
POSIX-style CLI option parsing:
`(getopts:getopts (2 (main-args)) 'getopts:short 'getopts:long)` with
declared short/long options.

## Notes

- All modules are ordinary newLISP source — read `modules/<name>.lsp`
  headers (`@module`, `@description`, `@syntax` doc-comments) for exact
  signatures, or run `newlispdoc -s -d modules/*.lsp`.
- Modules depending on external C libraries (`sqlite3`, `mysql`,
  `postgres`, `odbc`, `gsl`, `crypto`, `zlib`, `unix`) locate the shared
  library with per-platform path fallbacks at load time; a missing library
  makes the load fail with an import error.
