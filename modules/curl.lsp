;; @module curl.lsp
;; @description HTTP client functions using libcurl via FFI (Linux only)
;; @version 1.0 - initial version for newLISP Spark
;; @author newLISP Spark project
;; <h3>HTTP client functions using libcurl</h3>
;; This module implements the classic newLISP HTTP client functions
;; <tt>get-url</tt>, <tt>put-url</tt>, <tt>post-url</tt> and <tt>delete-url</tt>
;; entirely in newLISP on top of <b>libcurl</b>, using the extended FFI
;; (libffi). It requires a newLISP binary compiled with <tt>-DFFI</tt> and
;; a Linux shared libcurl library.
;;
;; Before using the module it must be loaded:
;; <pre>
;; (module "curl.lsp")
;; </pre>
;;
;; The four functions are defined in the MAIN context with the same
;; syntax and semantics as the legacy built-in C implementation:
;;
;; <pre>
;; (get-url str-url [str-option] [int-timeout [str-header]])
;; (put-url str-url str-content [str-option] [int-timeout [str-header]])
;; (post-url str-url str-content [str-content-type [str-option] [int-timeout [str-header]]])
;; (delete-url str-url [str-option] [int-timeout [str-header]])
;; </pre>
;;
;; str-option may contain any combination of the substrings
;; <tt>"header"</tt>, <tt>"list"</tt>, <tt>"debug"</tt> and <tt>"raw"</tt>.
;; <tt>"raw"</tt> disables redirect following. The environment variable
;; HTTP_PROXY is honored. URLs with the <tt>file://</tt> scheme are handled
;; natively (as in the legacy implementation).

(context 'Curl)

(when (zero? (& 1024 (sys-info -1)))
    (throw-error "curl.lsp: newLISP was compiled without libffi (FFI) support"))

;; ---------------- library discovery (Linux only) ----------------

(set 'files '(
    "/lib/x86_64-linux-gnu/libcurl.so.4"     ; Debian/Ubuntu 64-bit
    "/usr/lib/x86_64-linux-gnu/libcurl.so.4" ; Ubuntu 12.04 LTS 64-bit
    "/usr/lib/libcurl.so"                    ; Linux, BSD
    "/usr/lib64/libcurl.so"                  ; 64-bit CentOS/RedHat
    "/usr/local/lib/libcurl.so"              ; locally compiled
))

(set 'library (files (or
    (find true (map file? files))
    (throw-error "curl.lsp: cannot find the libcurl shared library"))))

;; ---------------- FFI imports ----------------
;; re-import of an FFI symbol is a safe no-op, so the module can be
;; loaded more than once.
;;
;; curl_easy_setopt is variadic in C.  It is imported once with a fixed
;; signature, passing the third argument as "void*".  On LP64 Linux both
;; longs and pointers travel in the same 64-bit general purpose register,
;; so one import serves string options (via (address str)), pointer
;; options and long options alike.  Fixed cif calls on a variadic
;; function are safe here because no float arguments are ever passed.

(import library "curl_global_init" "int" "long")
(import library "curl_easy_init" "void*")
(import library "curl_easy_setopt" "int" "void*" "int" "void*")
(import library "curl_easy_perform" "int" "void*")
(import library "curl_easy_cleanup" "void" "void*")
(import library "curl_easy_strerror" "char*" "int")
(import library "curl_easy_getinfo" "int" "void*" "int" "void*")
(import library "curl_slist_append" "void*" "void*" "char*")
(import library "curl_slist_free_all" "void" "void*")

;; ---------------- libcurl constants ----------------

(constant 'CURLOPT-URL             10002)
(constant 'CURLOPT-PROXY           10004)
(constant 'CURLOPT-POSTFIELDS      10015)
(constant 'CURLOPT-USERAGENT       10018)
(constant 'CURLOPT-HTTPHEADER      10023)
(constant 'CURLOPT-CUSTOMREQUEST   10036)
(constant 'CURLOPT-VERBOSE         41)
(constant 'CURLOPT-NOBODY          44)
(constant 'CURLOPT-POST            47)
(constant 'CURLOPT-FOLLOWLOCATION  52)
(constant 'CURLOPT-POSTFIELDSIZE   60)
(constant 'CURLOPT-HEADERFUNCTION  20079)
(constant 'CURLOPT-WRITEFUNCTION   20011)
(constant 'CURLOPT-TIMEOUT-MS      155)
(constant 'CURLOPT-CONNECTTIMEOUT-MS 156)
(constant 'CURLOPT-COPYPOSTFIELDS  10165)

(constant 'CURLINFO-RESPONSE-CODE  2097154) ; CURLINFO_LONG (0x200000) + 2
(constant 'CURL-GLOBAL-ALL         3)
(constant 'CONNECT-TIMEOUT         10000)   ; legacy default (ms)

;; CURLcode values used for legacy error message mapping
(constant 'CURLE-COULDNT-RESOLVE-HOST 6)
(constant 'CURLE-COULDNT-CONNECT      7)
(constant 'CURLE-OPERATION-TIMEDOUT   28)
(constant 'CURLE-GOT-NOTHING          52)

;; ---------------- transfer state and callbacks ----------------

(set 'body "")        ; accumulated response body
(set 'headers "")     ; accumulated response headers (final response only)
(set 'status-line "") ; status line of the final response

;; libcurl does not copy string option values, keep this one alive
(set 'user-agent (string "newLISP v" (sys-info -2)))

(define (write-cb ptr size nmemb userdata)
    (let ((bytes (* size nmemb)))
        (when (> bytes 0)
            (extend body (get-string ptr bytes))
            ;; honor a handler set with (xfer-event ...)
            (let ((h (sym "$transfer-event-handler" MAIN nil)))
                (when (and h (not (nil? (eval h))))
                    (MAIN:$transfer-event-handler bytes))))
        bytes))

(define (header-cb ptr size nmemb userdata)
    (let ((bytes (* size nmemb)))
        (when (> bytes 0)
            (let ((line (get-string ptr bytes)))
                ;; a new "HTTP/..." line starts a new response block
                ;; (redirect or 100-continue): keep only the final one
                (if (starts-with line "HTTP/")
                    (begin
                        (set 'status-line line)
                        (set 'headers "")
                        (set 'body ""))
                    (extend headers line))))
        bytes))

(set 'write-cb-ptr  (callback 'write-cb  "long" "void*" "long" "long" "void*"))
(set 'header-cb-ptr (callback 'header-cb "long" "void*" "long" "long" "void*"))

(curl_global_init CURL-GLOBAL-ALL)

;; ---------------- helpers ----------------

;; parse legacy trailing arguments: [str-option|int-timeout [int-timeout] [str-header]]
;; returns (option-string timeout custom-header)
(define (parse-options opt-args)
    (let ((opt "") (timeout 0) (custom-header nil) (a nil))
        (when (and opt-args (not (nil? (first opt-args))))
            (set 'a (pop opt-args))
            (if (number? a)
                (set 'timeout (int a))
                (begin
                    (set 'opt a)
                    (when opt-args
                        (set 'timeout (int (pop opt-args)))))))
        ;; legacy: a custom header is only read when a timeout was given
        (when (and (!= timeout 0) opt-args)
            (set 'custom-header (pop opt-args)))
        (list opt timeout custom-header)))

;; split a custom header block into single header lines
(define (header-lines str)
    (let ((s (replace "\r" (copy str) "")))
        (filter (fn (l) (!= l "")) (map trim (parse s "\n")))))

;; map a CURLcode to a legacy style error message
(define (curl-error rc)
    (string "ERR: "
        (cond
            ((= rc CURLE-COULDNT-RESOLVE-HOST) "DNS resolution failed")
            ((= rc CURLE-COULDNT-CONNECT)      "Connection failed")
            ((= rc CURLE-OPERATION-TIMEDOUT)   "Operation timed out")
            ((= rc CURLE-GOT-NOTHING)          "HTTP no response from server")
            (true (curl_easy_strerror rc)))))

;; file:// requests are handled natively, with the exact legacy semantics
(define (file-request method url data)
    (let ((path (7 url)))
        (case method
            ("GET" (or (read-file path) "ERR: HTTP file operation failed"))
            ("PUT" (if (write-file path data)
                       (string (length data) " bytes written")
                       "ERR: HTTP file operation failed"))
            ("DELETE" (if (delete-file path)
                          "file deleted"
                          "ERR: HTTP file operation failed"))
            (true "ERR: HTTP bad formed URL"))))

;; ---------------- the request engine ----------------

(define (http-request method url data content-type opt-args)
    (letn ((opts (parse-options opt-args))
           (opt (opts 0))
           (timeout (opts 1))
           (custom-header (opts 2))
           (head-request (find "header" opt))
           (list-flag    (find "list" opt))
           (debug-flag   (find "debug" opt))
           (raw-flag     (find "raw" opt))
           (lu (lower-case url)))
        (if (not (or (starts-with lu "http://") (starts-with lu "https://")))
            "ERR: HTTP bad formed URL"
            (letn ((curl (curl_easy_init))
                   (slist 0)
                   (slist-lines '())
                   (rc 0)
                   (lbuf (dup "\000" 8))
                   (code 0)
                   (proxy (env "HTTP_PROXY")))
                (when (zero? curl)
                    (throw-error "curl.lsp: curl_easy_init failed"))
                (set 'body "") (set 'headers "") (set 'status-line "")
                (curl_easy_setopt curl CURLOPT-URL (address url))
                (curl_easy_setopt curl CURLOPT-WRITEFUNCTION write-cb-ptr)
                (curl_easy_setopt curl CURLOPT-HEADERFUNCTION header-cb-ptr)
                (when (and proxy (!= proxy ""))
                    (curl_easy_setopt curl CURLOPT-PROXY (address proxy)))
                (curl_easy_setopt curl CURLOPT-FOLLOWLOCATION
                    (if raw-flag 0 1))
                (curl_easy_setopt curl CURLOPT-CONNECTTIMEOUT-MS
                    (if (> timeout 0) timeout CONNECT-TIMEOUT))
                (when (> timeout 0)
                    (curl_easy_setopt curl CURLOPT-TIMEOUT-MS timeout))
                (when debug-flag
                    (curl_easy_setopt curl CURLOPT-VERBOSE 1))
                (if custom-header
                    (set 'slist-lines (header-lines custom-header))
                    (curl_easy_setopt curl CURLOPT-USERAGENT (address user-agent)))
                (case method
                    ("GET"
                        (when head-request
                            (curl_easy_setopt curl CURLOPT-NOBODY 1)))
                    ("POST"
                        (curl_easy_setopt curl CURLOPT-POST 1)
                        (curl_easy_setopt curl CURLOPT-POSTFIELDSIZE (length data))
                        (curl_easy_setopt curl CURLOPT-COPYPOSTFIELDS (address data))
                        ;; legacy: Content-Type is always sent for POST
                        (push (string "Content-Type: "
                                  (or content-type "application/x-www-form-urlencoded"))
                              slist-lines -1))
                    ("PUT"
                        (curl_easy_setopt curl CURLOPT-CUSTOMREQUEST (address "PUT"))
                        (curl_easy_setopt curl CURLOPT-POSTFIELDSIZE (length data))
                        (curl_easy_setopt curl CURLOPT-COPYPOSTFIELDS (address data))
                        (if custom-header
                            (push "Content-Type;" slist-lines -1) ; legacy sends none
                            (push "Content-Type: text/html" slist-lines -1)))
                    ("DELETE"
                        (curl_easy_setopt curl CURLOPT-CUSTOMREQUEST (address "DELETE"))))
                (when slist-lines
                    (dolist (line slist-lines)
                        (set 'slist (curl_slist_append slist line)))
                    (curl_easy_setopt curl CURLOPT-HTTPHEADER slist))
                (set 'rc (curl_easy_perform curl))
                (when (!= slist 0)
                    (curl_slist_free_all slist))
                (curl_easy_getinfo curl CURLINFO-RESPONSE-CODE (address lbuf))
                (set 'code (get-long (address lbuf)))
                (curl_easy_cleanup curl)
                (cond
                    ((!= rc 0)
                        (curl-error rc))
                    (head-request
                        headers)
                    ((= code 204)
                        "ERR: HTTP not content")
                    ((>= code 400)
                        (if list-flag
                            (list headers body status-line code)
                            (string "ERR: " status-line body)))
                    (list-flag
                        (list headers body status-line code))
                    (true
                        body))))))

(define (request method url data content-type opt-args)
    (if (starts-with (lower-case url) "file://")
        (file-request method url data)
        (http-request method url data content-type opt-args)))

;; ---------------- public API in MAIN (legacy drop-in) ----------------

(context 'MAIN)

;; On binaries up to 10.7.6 the four URL functions still exist as
;; protected C primitives with the same API; define the libcurl FFI
;; versions only when the built-ins are absent (10.8 and later).
(unless (and (sym "get-url" MAIN nil)
             (primitive? (eval (sym "get-url" MAIN nil))))

;; @syntax (get-url <str-url> [<str-option>] [<int-timeout> [<str-header>]])
(define (get-url url)
    (Curl:request "GET" url nil nil (args)))

;; @syntax (put-url <str-url> <str-content> [<str-option>] [<int-timeout> [<str-header>]])
(define (put-url url data)
    (Curl:request "PUT" url data nil (args)))

;; @syntax (post-url <str-url> <str-content> [<str-content-type> [<str-option>] [<int-timeout> [<str-header>]]])
(define (post-url url data)
    (let ((opt-args (args)))
        (Curl:request "POST" url data
            (if opt-args (pop opt-args) nil)
            opt-args)))

;; @syntax (delete-url <str-url> [<str-option>] [<int-timeout> [<str-header>]])
(define (delete-url url)
    (Curl:request "DELETE" url nil nil (args)))

) ; end unless

;; eof
