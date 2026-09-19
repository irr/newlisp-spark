/* nl-web.c --- HTTP network protocol routines for newLISPD

    Copyright (C) 2020 Lutz Mueller

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

*/

#include "newlisp.h"
#include <errno.h>
#include "protos.h"

#include <sys/types.h>
#include <sys/time.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/wait.h>
#include <netdb.h>
#include <netinet/in.h>
#include <arpa/inet.h>

/* from newlisp.c */
extern int httpSafe;

char * requestMethod[] = {"GET", "HEAD", "PUT", "PUT", "POST", "DELETE"};

ssize_t readFile(char * fileName, char * * buffer);
size_t parseValue(char * str);
CELL * base64(CELL * params, int type);

/* ------------------- HTTP client: modules/curl.lsp --------------------

   The HTTP client functions get-url, put-url, post-url and delete-url
   are implemented in newLISP on top of libcurl using the FFI, see
   modules/curl.lsp.  URL support in load, save, read-file, write-file,
   append-file and delete-file delegates to those functions.  When the
   module is not loaded, URL file operations fail as if the file could
   not be accessed.
*/

CELL * curlModuleRequest(char * funcName, char * fileName, CELL * params)
{
SYMBOL * sPtr;
CELL * head, * result;

if((sPtr = lookupSymbol(funcName, mainContext)) == NULL) return(NULL);
if(((CELL *)sPtr->contents)->type != CELL_LAMBDA) return(NULL);

head = stuffString(fileName);
head->next = params;
executeSymbol(sPtr, head, &result);

return(result);
}

/* TRUE when a curlModuleRequest() result carries an "ERR: ..." message */
int isCurlErrorResult(CELL * result)
{
return(result->type == CELL_STRING &&
       strncmp((char *)result->contents, "ERR:", 4) == 0);
}

size_t parseValue(char * str)
{
while(!isDigit((unsigned char)*str) && *str != 0) ++str;
return atol(str);
}

/***************************************************************************
 *                                  _   _ ____  _
 *  Project                     ___| | | |  _ \| |
 *                             / __| | | | |_) | |
 *                            | (__| |_| |  _ <| |___
 *                             \___|\___/|_| \_\_____|
 *
 * Copyright (C) 1998 - 2004, Daniel Stenberg, <daniel@haxx.se>, et al.
 *
 * This software is licensed as described in the file COPYING, which
 * you should have received as part of this distribution. The terms
 * are also available at http://curl.haxx.se/docs/copyright.html.
 *
 * You may opt to use, copy, modify, merge, publish, distribute and/or sell
 * copies of the Software, and permit persons to whom the Software is
 * furnished to do so, under the terms of the COPYING file.
 *
 * This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY
 * KIND, either express or implied.
 *
 * $Id: base64.c,v 1.32 2004/12/15 01:38:25 danf Exp $
 ***************************************************************************/

/* Base64 encoding/decoding

   this file from the cURL project is included in nl-web.c for the
   newLISP functions 'base64-enc' and 'base64-dec' 

   all #include statements have and the test harness rootines have
   been stripped.  2005-1-6 Lutz Mueller
*/


static void decodeQuantum(unsigned char *dest, const char *src)
{
  unsigned int x = 0;
  int i;
  for(i = 0; i < 4; i++) {
    if(src[i] >= 'A' && src[i] <= 'Z')
      x = (x << 6) + (unsigned int)(src[i] - 'A' + 0);
    else if(src[i] >= 'a' && src[i] <= 'z')
      x = (x << 6) + (unsigned int)(src[i] - 'a' + 26);
    else if(src[i] >= '0' && src[i] <= '9')
      x = (x << 6) + (unsigned int)(src[i] - '0' + 52);
    else if(src[i] == '+')
      x = (x << 6) + 62;
    else if(src[i] == '/')
      x = (x << 6) + 63;
    else if(src[i] == '=')
      x = (x << 6);
  }

  dest[2] = (unsigned char)(x & 255);
  x >>= 8;
  dest[1] = (unsigned char)(x & 255);
  x >>= 8;
  dest[0] = (unsigned char)(x & 255);
}

/*
 * Curl_base64_decode()
 *
 * Given a base64 string at src, decode it into the memory pointed to by
 * dest. Returns the length of the decoded data.
 */
size_t Curl_base64_decode(const char *src, char *dest)
{
  int length = 0;
  int equalsTerm = 0;
  int i;
  int numQuantums;
  unsigned char lastQuantum[3];
  size_t rawlen=0;

  while((src[length] != '=') && src[length])
    length++;
  while(src[length+equalsTerm] == '=')
    equalsTerm++;

  if(equalsTerm > 3) equalsTerm = 3; /* LM added 2006-09-08 */

  numQuantums = (length + equalsTerm) / 4;

  if(numQuantums == 0) return(0);

  rawlen = (numQuantums * 3) - equalsTerm;

  for(i = 0; i < numQuantums - 1; i++) {
    decodeQuantum((unsigned char *)dest, src);
    dest += 3; src += 4;
  }

  decodeQuantum(lastQuantum, src);
  for(i = 0; i < 3 - equalsTerm; i++)
    dest[i] = lastQuantum[i];

  return rawlen;
}

#define BASE64_ENC 0
#define BASE64_DEC 1

CELL * p_base64Enc(CELL * params) { return(base64(params, BASE64_ENC)); }
CELL * p_base64Dec(CELL * params) { return(base64(params, BASE64_DEC)); }

CELL * base64(CELL * params, int type)
{
char * inPtr;
char * outPtr;
size_t sizein, sizeout;
int emptyFlag = 0;

params = getStringSize(params, &inPtr, &sizein, TRUE);
emptyFlag = getFlag(params);

if(type == BASE64_ENC)
    {
    if(sizein == 0)
        return(emptyFlag ? stuffString("") : stuffString("===="));
    if((sizeout = Curl_base64_encode(inPtr, sizein, &outPtr)) == 0)
        return(stuffString(""));
    }
else    /* BASE64_DEC */
    {
    outPtr = allocMemory((sizein * 3) / 4 + 9);
    sizeout = Curl_base64_decode(inPtr, outPtr);
    *(outPtr + sizeout) = 0;
    }
    
/*
strCell = getCell(CELL_STRING);
strCell->contents = (UINT)outPtr;
strCell->aux = sizeout + 1;
return(strCell);
*/

return(makeStringCell(outPtr, sizeout));
}

/* ---- Base64 Encoding --- */
static const char table64[]=
  "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

/*
 * Curl_base64_encode()
 *
 * Returns the length of the newly created base64 string. The third argument
 * is a pointer to an allocated area holding the base64 data. If something
 * went wrong, -1 is returned.
 *
 */
size_t Curl_base64_encode(const char *inp, size_t insize, char **outptr)
{
  unsigned char ibuf[3];
  unsigned char obuf[4];
  int i;
  int inputparts;
  char *output;
  char *base64data;

  char *indata = (char *)inp;

  *outptr = NULL; /* set to NULL in case of failure before we reach the end */

  if(0 == insize)
    insize = strlen(indata);

  base64data = output = (char*)malloc(insize*4/3+4);
  if(NULL == output)
    return 0;

  while(insize > 0) {
    for (i = inputparts = 0; i < 3; i++) {
      if(insize > 0) {
        inputparts++;
        ibuf[i] = *indata;
        indata++;
        insize--;
      }
      else
        ibuf[i] = 0;
    }

    obuf [0] = (ibuf [0] & 0xFC) >> 2;
    obuf [1] = ((ibuf [0] & 0x03) << 4) | ((ibuf [1] & 0xF0) >> 4);
    obuf [2] = ((ibuf [1] & 0x0F) << 2) | ((ibuf [2] & 0xC0) >> 6);
    obuf [3] = ibuf [2] & 0x3F;

    switch(inputparts) {
    case 1: /* only one byte read */
      snprintf(output, 5, "%c%c==",
               table64[obuf[0]],
               table64[obuf[1]]);
      break;
    case 2: /* two bytes read */
      snprintf(output, 5, "%c%c%c=",
               table64[obuf[0]],
               table64[obuf[1]],
               table64[obuf[2]]);
      break;
    default:
      snprintf(output, 5, "%c%c%c%c",
               table64[obuf[0]],
               table64[obuf[1]],
               table64[obuf[2]],
               table64[obuf[3]] );
      break;
    }
    output += 4;
  }
  *output=0;
  *outptr = base64data; /* make it return the actual data memory */

  return strlen(base64data); /* return the length of the new data */
}
/* ---- End of Base64 Encoding ---- */


/* --------------------------- HTTP server mode -----------------------------
   Handles GET, POST, PUT and DELETE requests
   handles queries in GET requests and sets environment variables 
   DOCUMENT_ROOT, REQUEST_METHOD, SERVER_SOFTWARE and QUERY_STRING,
   and when present in client request header HTTP_HOST, HTTP_USER_AGENT
   and HTTP_COOKIE. REMOTE_ADDR is set when the client connects.
   Subset HTTP/1.0 compliant.
*/
#ifndef LIBRARY
/* #define DEBUGHTTP  */
#define SERVER_SOFTWARE "newLISP/10.8"

int sendHTTPmessage(int status, char * description, char * request);
void handleHTTPcgi(char * command, char * query, ssize_t querySize);
size_t readHeader(char * buff, int * pragmaFlag);
ssize_t readPayLoad(ssize_t size, char * content, int outFile, char * request);
int endsWith(char * str, char * ext);
char * getMediaType(char * request);
void url_decode(char *dest, char *src);

void sendHTTPpage(char * content, size_t size, char * media)
{
int pos = 0;
char status[128];

memset(status, 0, 128);
if(strncmp(content, "Status:", 7) == 0)
    {
    /* get content after */
    while(*(content + pos) >= 32) pos++;
    memcpy(status, content + 7, pos - 7); 
    content = content + pos;
    if(size) size -= pos;
    while(*content == '\r' || *content == '\n') { content++; size--; }
    }
else
    memcpy(status, "200 OK", 7);

varPrintf(OUT_CONSOLE, "HTTP/1.0 %s\r\n", status);
varPrintf(OUT_CONSOLE, "Server: newLISP v.%d (%s)\r\n", version, OSTYPE);
#ifdef DEBUGHTTP
puts("# Header sent:");
printf("HTTP/1.0 %s\r\n", status);
printf("Server: newLISP v.%d (%s)\r\n", version, OSTYPE);
#endif

if(media != NULL)
    {
    varPrintf(OUT_CONSOLE, "Content-length: %d\r\nContent-type: %s\r\n\r\n", size, media);
#ifdef DEBUGHTTP
    printf("Content-length: %d\r\nContent-type: %s\r\n\r\n", (int)size, media);
#endif
    }
size = write(fileno(IOchannel), content, size);
fflush(IOchannel);
fclose(IOchannel);
IOchannel = NULL;
#ifdef DEBUGHTTP
printf("# content:%s:\r\n", content);
fflush(stdout);
#endif
}

#define MAX_BUFF 1024
#define ERROR_404 "File or Directory not found"
#define ERROR_411 "Length required for"
#define ERROR_500 "Server error"
#define DEFAULT_PAGE_1 "index.html"
#define DEFAULT_PAGE_2 "index.cgi"
#define CGI_EXTENSION ".cgi"
#define MEDIA_TEXT "text/plain"


int executeHTTPrequest(char * request, int type)
{
char * sptr;
char * query;
char * content = NULL;
char * decoded;
char buff[MAX_BUFF];
ssize_t transferred, size;
char * mediaType;
CELL * result = NULL;
int outFile;
int pragmaFlag;
int len;
char * fileMode = "w";

if(chdir(startupDir) < 0)
    fatalError(ERR_IO_ERROR, 0, 0);
query = sptr = request;

setenv("DOCUMENT_ROOT", startupDir, 1);
setenv("SERVER_SOFTWARE", SERVER_SOFTWARE, 1);
setenv("REQUEST_METHOD", requestMethod[type], 1);

#ifdef DEBUGHTTP
printf("# HTTP request:%s:%s:\r\n", request, requestMethod[type]);
#endif

/* stuff after request */
while(*sptr > ' ') ++sptr;
*sptr = 0;
while(*query != 0 && *query != '?') ++query;
if(*query == '?')
    {
    *query = 0;
    query++;
    }

setenv("QUERY_STRING", query, 1);

/* do url_decode */
decoded = alloca(strlen(request) + 1);
url_decode(decoded, request);
request = decoded;

setenv("REQUEST_URI", request, 1); /* 10.7.4 */

/* change to base dir of request file */
sptr = request + strlen(request);
while(*sptr != '/' && sptr != request) --sptr;
if(*sptr == '/') 
    {
    *sptr = 0;
    sptr++;
    if(chdir(request))
        {
        sendHTTPmessage(404, ERROR_404, request);
        return(TRUE);
        }
    request = sptr;
    }

if((len = strlen(request)) == 0)
    {
    if(isFile(DEFAULT_PAGE_2, 0) == 0) 
        request = DEFAULT_PAGE_2;
    else
        request = DEFAULT_PAGE_1;
    len = strlen(request);
    }

size = readHeader(buff, &pragmaFlag);
switch(type)
    {
    case HTTP_GET:
    case HTTP_HEAD:
        if(endsWith(request, CGI_EXTENSION))
            handleHTTPcgi(request, query, strlen(query));
        else
            {
            mediaType = getMediaType(request);

            if(type == HTTP_HEAD)
                {
                snprintf(buff, MAX_BUFF - 1, 
                    "Content-length: %"PRId64"\r\nContent-type: %s\r\n\r\n",
                    fileSize(request), mediaType);
                sendHTTPpage(buff, strlen(buff), NULL);
                }
            else
                {
                if((size = readFile(request, &content)) == -1)
                    sendHTTPmessage(404, ERROR_404, request);
                else
                    sendHTTPpage(content, size, mediaType);
                if(content) free(content);
                }
            }
        break;

    case HTTP_DELETE:
        if(httpSafe)
            {
            sendHTTPpage("Server in safe mode", 19, MEDIA_TEXT);
            break;
            }
            
        if(unlink(request) != 0)    
            sendHTTPmessage(500, "Could not delete", request);
        else
            sendHTTPpage("File deleted", 12, MEDIA_TEXT);
        break;

    case HTTP_POST:
        if(!size)
            {
            sendHTTPmessage(411, ERROR_411, request);
            break;
            }

        query = callocMemory(size + 1);

        if(readPayLoad(size, query, 0, request) == -1)
            {
            free(query);
            break;
            }

        handleHTTPcgi(request, query, size);
        free(query); 
        break;

    case HTTP_PUT:
        if(httpSafe)
            {
            sendHTTPpage("Server in safe mode", 19, request);
            break;
            }
        if(pragmaFlag) fileMode = "a";

        if(!size)
            {
            sendHTTPmessage(411, ERROR_411, request);
            break;
            }

        if( (outFile = openFile(request, fileMode, NULL)) == (int)-1)
            {
            sendHTTPmessage(500, "cannot create file", request);
            break;
            }

        transferred = readPayLoad(size, buff, outFile, request);
        close(outFile);
        if(transferred != -1)
            {
            snprintf(buff, 255, "%d bytes transferred for %s\r\n", (int)transferred, request);
            sendHTTPpage(buff, strlen(buff), MEDIA_TEXT);
            }
        break;

    default:
        break;
    }

if(chdir(startupDir) < 0) fatalError(ERR_IO_ERROR, 0, 0);
if(result != NULL) deleteList(result);
return(TRUE);
}


int sendHTTPmessage(int status, char * desc, char * req)
{
char msg[256];

snprintf(msg, 256, "Status:%d %s\r\nERR:%d %s: %s\r\n", status, desc, status, desc, req);
sendHTTPpage(msg, strlen(msg), MEDIA_TEXT);
return(0);
}


/* remove leading white space */ 
char * trim(char * buff) 
{
char * ptr = buff;
while(*ptr <= ' ') ptr++;
return(ptr);
}

/* retrieve rest of header */
size_t readHeader(char * buff, int * pragmaFlag)
{
size_t size = 0;
int offset;
char numStr[16];

*pragmaFlag = 0;

memset(buff, 0, MAX_LINE);

setenv("HTTP_HOST", "", 1);
setenv("HTTP_USER_AGENT", "", 1);
setenv("HTTP_COOKIE", "", 1);
setenv("HTTP_AUTHORIZATION", "", 1);

while(fgets(buff, MAX_LINE - 1, IOchannel) != NULL)
    {
    if(strcmp(buff, "\r\n") == 0 || strcmp(buff, "\n") == 0) break;

    /* trim trailing white space */
    offset = strlen(buff) - 1;
    while(offset > 0 && *(buff + offset) <= ' ') 
        *(buff + offset--) = 0; 

    if(my_strnicmp(buff, "content-length:", 15) == 0)
        {
        size = parseValue(buff + 15);
        snprintf(numStr, 16, "%llu", (long long unsigned int)size);
        setenv("CONTENT_LENGTH", numStr, 1);
        }
    if(my_strnicmp(buff, "pragma: append", 14) == 0)
        *pragmaFlag = TRUE;

    /* trim leading white space */
    if(my_strnicmp(buff, "content-type:", 13) == 0)
        setenv("CONTENT_TYPE", trim(buff + 13), 1);
    if(my_strnicmp(buff, "Host:", 5) == 0)
        setenv("HTTP_HOST", trim(buff + 5), 1);
    if(my_strnicmp(buff, "User-Agent:", 11) == 0)
        setenv("HTTP_USER_AGENT", trim(buff + 11), 1);
    if(my_strnicmp(buff, "Cookie:", 7) == 0)
        setenv("HTTP_COOKIE", trim(buff + 7), 1);
    if(my_strnicmp(buff, "Authorization:", 14) == 0)
        setenv("HTTP_AUTHORIZATION", trim(buff + 14), 1);
    }


return(size);
}


ssize_t readPayLoad(ssize_t size, char * buff, int outFile, char * request)
{
ssize_t bytes, readsize;
size_t offset = 0, transferred = 0;

#ifdef DEBUGHTTP
printf("# Payload size:%ld\r\n", (long)size);
#endif

while(size > 0)
    {
    readsize = (size > MAX_BUFF) ? MAX_BUFF : size;
    bytes = read(fileno(IOchannel), buff + offset, readsize);

#ifdef DEBUGHTTP
    printf("Payload bytes:%ld:%s:\r\n", (long)bytes, buff + offset);
#endif

    if(bytes <= 0)
        {
        sendHTTPmessage(500, "Problem reading data", request);
        return(-1);
        }

    if(outFile)
        {
        if(write(outFile, buff + offset, bytes) != bytes)
            {
            sendHTTPmessage(500, "Cannot create file", request);
            return(-1);
            }
        }
    else
        offset += bytes;

    transferred += bytes;
    size -= bytes;
    }
fflush(NULL);
return(transferred);
}



void handleHTTPcgi(char * request, char * query, ssize_t querySize)
{
FILE * handle;
char * command;
char * content = NULL;
ssize_t size;
char tempfile[PATH_MAX];

srandom(milliSecTime());

#ifdef DEBUGHTTP
printf("# CGI request:%s:%s:\r\n", request, query);
#endif

if(isFile(request, 0) != 0)
    {
    sendHTTPmessage(404, ERROR_404, request);
    return;
    }

if(isFile(tempDir, 0) != 0)
    {
    sendHTTPmessage(500, "cannot find tmp directory", request);
    return;
    }

size = strlen(request) + PATH_MAX;
command = alloca(size);
snprintf(tempfile, PATH_MAX, "%s/nl%04x-%08x-%08x", 
    tempDir, (unsigned int)size, (unsigned int)random(), (unsigned int)random());

snprintf(command, size - 1, "./\"%s\" > %s", request, tempfile);

if((handle = popen(command, "w")) == NULL)
    {
    sendHTTPmessage(500, "failed creating pipe", request);
    return;
    }

if((size = fwrite(query, 1, querySize, handle)) < 0)
    fatalError(ERR_IO_ERROR, 0, 0);

fflush(handle);
pclose(handle);

size = readFile(tempfile, &content);
if(size == -1)  
    sendHTTPmessage(500, "cannot read output of", tempfile);
else
    sendHTTPpage(content, size, NULL);
    
#ifdef DEBUGHTTP
printf("# Temporary file: %s\n", tempfile);
#else
unlink(tempfile);
#endif

if(content) free(content);
}   


int endsWith(char * str, char * ext)
{
size_t size, len;

size = strlen(str);
len =  strlen(ext);

return(strncmp(str + size - len, ext, len) == 0);
}


typedef struct
    {
    char * extension;
    char * type;
    } T_MEDIA_TYPE;

T_MEDIA_TYPE mediaType[] = {
    {".avi", "video/x-msvideo"},
    {".css", "text/css"},
    {".gif", "image/gif"},
    {".htm", "text/html"},
    {".html","text/html"},
    {".jpg", "image/jpeg"},
    {".js", "application/javascript"},
    {".mov", "video/quicktime"},
    {".mp3", "audio/mpeg"},
    {".mpg", "video/mpeg"},
    {".pdf", "application/pdf"},
    {".png", "image/png"},
    {".wav", "audio/x-wav"},
    {".zip", "application/zip"},
    { NULL, NULL},
};

char * getMediaType(char * request)
{
int i;

for(i = 0; mediaType[i].extension != NULL; i++)
    {
    if(endsWith(request, mediaType[i].extension))
        return(mediaType[i].type);
    }
    
return(MEDIA_TEXT);
}

 
void url_decode(char *dest, char *src)
{
char code[3] = {0};
unsigned int ascii = 0;
char *end = NULL;

while(*src)
    {
    if(*src == '%')
        {
        memcpy(code, ++src, 2);
        ascii = strtoul(code, &end, 16);
        *dest++ = (char)ascii;
        src += 2;
        }
    else
        *dest++ = *src++;
    }
*dest = 0;
}

#endif /* ifndef LIBRARY */
/* eof */

