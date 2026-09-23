#!/usr/bin/env newlisp

;; Fetch a JSON file (URL or path), parse it, and write Markdown.
;;
;;   ./newlisp examples/json2md.lsp <url-or-file> [output.md]
;;
;; Objects become key/value tables when every value is a scalar, otherwise
;; headings. An array of flat objects with the same keys becomes one table.
;; json-parse cannot tell {"a":1} from [["a",1]]; that shape is treated as
;; an object.

(define (first-file paths)
  (let (hit nil)
    (dolist (p paths)
      (when (and (not hit) p (file? p))
        (set 'hit p)))
    hit))

(define (load-curl)
  (letn ((script ((main-args) 1))
         (dir (replace "[^/]+$" (or (real-path script) script) "" 0))
         (home (or (env "HOME") ""))
         (ndir (env "NEWLISPDIR"))
         (found (first-file (list
                   (append dir "../modules/curl.lsp")
                   (if ndir (append ndir "/modules/curl.lsp"))
                   (append home "/.local/share/newlisp/modules/curl.lsp")
                   "/usr/local/share/newlisp/modules/curl.lsp"))))
    (if found
        (load found)
        (throw-error "curl.lsp not found; run sudo make install or make install_home"))))

(define (fetch src)
  (if (or (starts-with src "http://")
          (starts-with src "https://")
          (starts-with src "file://"))
      (begin
        (load-curl)
        (let (body (get-url src))
          (when (or (not body) (starts-with (string body) "ERR:"))
            (throw-error (or body "fetch failed")))
          body))
      (or (read-file src)
          (throw-error (string "cannot read " src)))))

(define (scalar? x)
  (or (string? x) (number? x) (symbol? x)))

(define (json-object? x)
  (and (list? x)
       (not (empty? x))
       (for-all (fn (pair)
                  (and (list? pair)
                       (= 2 (length pair))
                       (string? (first pair))))
                x)))

(define (flat-object? obj)
  (and (json-object? obj)
       (for-all (fn (pair) (scalar? (last pair))) obj)))

(define (same-keys? rows)
  (let (keys (sort (map first (first rows))))
    (for-all (fn (row) (= keys (sort (map first row)))) (rest rows))))

(define (table-rows? x)
  (and (list? x)
       (not (empty? x))
       (for-all flat-object? x)
       (same-keys? x)))

(define (md-cell x)
  (cond
    ((or (nil? x) (= x 'null)) "")
    ((string? x)
     (let (cell (replace "\n" x " "))
       (replace "\r" cell "")
       (replace "|" cell "\\|")))
    (true (string x))))

(define (heading level title)
  (string (dup "#" (min 6 (max 1 level))) " " title "\n\n"))

(define (object-table obj)
  (join (append
          '("| key | value |" "| --- | --- |")
          (map (fn (pair)
                 (format "| %s | %s |" (md-cell (first pair)) (md-cell (last pair))))
               obj))
        "\n"))

(define (rows-table rows)
  (letn ((keys (map first (first rows)))
         (line (fn (cells) (string "| " (join cells " | ") " |"))))
    (join (append
            (list (line (map md-cell keys))
                  (line (map (fn (k) "---") keys)))
            (map (fn (row)
                   (line (map (fn (k) (md-cell (lookup k row))) keys)))
                 rows))
          "\n")))

(define (to-md x level)
  (cond
    ((nil? x) "_(empty)_\n")
    ((json-object? x)
     (letn ((scalars (filter (fn (pair) (scalar? (last pair))) x))
            (nested (filter (fn (pair) (not (scalar? (last pair)))) x))
            (parts '()))
       (when scalars
         (push (string (object-table scalars) "\n\n") parts -1))
       (dolist (pair nested)
         (push (string (heading level (first pair))
                       (to-md (last pair) (+ level 1)))
               parts -1))
       (join parts "")))
    ((table-rows? x)
     (string (rows-table x) "\n"))
    ((list? x)
     (if (for-all scalar? x)
         (string (join (map (fn (item) (string "- " (md-cell item))) x) "\n") "\n")
         (join (map (fn (item)
                      (string (heading level (format "item %d" (+ $idx 1)))
                              (to-md item (+ level 1))))
                    x)
               "")))
    (true (string (md-cell x) "\n"))))

(define (title-of src)
  (let (name (last (parse (first (parse src "?")) "/")))
    (replace {\.json$} name "" 0)
    (if (= name "") "JSON" name)))

(set 'cli (2 (main-args)))
(unless cli
  (println "usage: newlisp json2md.lsp <url-or-file> [output.md]")
  (exit 1))

(set 'src (cli 0))
(set 'raw (fetch src))
(set 'bom (pack "bbb" 239 187 191))
(when (starts-with raw bom)
  (set 'raw ((length bom) raw)))
(set 'data (json-parse raw))
(when (json-error)
  (println "json-parse: " (json-error))
  (exit 1))

(set 'md (string (heading 1 (title-of src)) (to-md data 2)))
(if (> (length cli) 1)
    (begin
      (write-file (cli 1) md)
      (println (cli 1)))
    (print md))
(exit 0)
