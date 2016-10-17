\ file transfer server
\ implemented for lwip callbacks only

vocabulary fts-v
also fts-v definitions

warning off

0 value fts-pcb
0 value fts-listen-pcb

\needs $=  : $=  ( $1 $2 -- )  compare 0=  ;

\ -trailing
\ also will strip newlines
\ derived from kernel.fth

: printable?  ( n -- flag ) \ true if n is a printable ascii character
   dup bl th 7f within  swap  th 80  th ff  between  or
;

: white-space?  ( n -- flag ) \ true is n is non-printable? or a blank
   dup printable? 0=  swap  bl =  or
;

: -trailing  ( adr len -- adr len' )
   dup  0  ?do   2dup + 1- c@   white-space? 0=  ?leave  1-    loop
;

\ end from kernel.fth


\ reply-send
\ re-implemented for callbacks only
\ derived from tcpnew.fth

: $tx  ( $data -- )
   fts-pcb tcp-write drop
;


\ send-file
\ re-implemented for callbacks only
\ derived from sendfile.fth

false value send-more?  \ file being sent not yet at end of file
0 value bytes-tx        \ count of bytes queued
0 value bytes-sent      \ count of bytes sent

: send-some  ( -- )
   begin                                ( )
      fts-pcb tcp-sendbuf               ( len )
      \ ." Available send window of " dup .d ." bytes" cr
      dup 0= if
         \ ." Window empty" cr
         drop exit
      then                              ( len )

      /chunk min                        ( thislen )
      chunk swap  ['] read-fid catch  if  ( x x )
         \ ." No more to send" cr
         2drop                          ( )
         close-fid
         false to send-more?
         exit
      then                              ( len )
      chunk swap                        ( adr len )
   dup while                            ( adr len )
      dup bytes-tx + to bytes-tx
      $tx                               ( )
      \ bytes-tx ." Have queued " .d ." bytes" cr
   repeat                               ( adr 0 )
   \ NOT REACHED
   \ ." Window exhausted" cr
   2drop                                ( )
;

: sent  ( len pcb arg -- err )
   2drop                                ( len )
   bytes-sent + to bytes-sent           ( )
   \ ." Have sent " bytes-sent .d ." bytes" cr
   send-more?  if                       ( )
      send-some
   else
      bytes-sent bytes-tx =  if
         \ ." All bytes sent" cr
         fts-pcb close-connection
      then
   then                                 ( )
   ERR_OK                               ( err )
;

: send-start  ( -- )
   true to send-more?
   0 to bytes-tx
   0 to bytes-sent
   ['] sent fts-pcb tcp-sent
   send-some
;

defer send-file-not-found  ( -- )
' noop is send-file-not-found

: send-file  ( filename$ -- )
   ['] open-fid catch  if       ( x x )
      2drop                     ( )
      send-file-not-found       ( )
      fts-pcb close-connection
   else                         ( )
      send-start                ( )
   then                         ( )
;

\ end from sendfile.fth


\ receive message parser
\ for callbacks only

defer $rx

: $rx-data  ( $data -- )  write-fid  ;

: $rx-cmd  ( $data -- )
   -trailing
   bl left-parse-string                 ( $tail $head )

   " list" 2over $= if
      2drop 2drop                       ( )
      ['] $tx to reply-send
      reply{ dir }reply
      fts-pcb close-connection
      exit
   then

   " get" 2over $= if                   ( $tail $head )
      2drop                             ( $tail )
      send-file                         ( )
      exit
   then

   " put" 2over $= if                   ( $tail $head )
      2drop                             ( $tail )
      create-fid                        ( )
      ['] $rx-data to $rx
      exit
   then

   " remove" 2over $= if                ( $tail $head )
      2drop                             ( $tail )
      ['] delete-file catch  if  2drop  then
      fts-pcb close-connection
      exit                              ( )
   then

   " restart" 2over $= if               ( $tail $head )
      2drop 2drop                       ( )
      fts-pcb close-connection
      restart
      exit
   then

   2drop 2drop                          ( )
;

' $rx-cmd to $rx


\ receiver accepter unlisten listen
\ re-implemented for callbacks only
\ derived from tcpnew.fth

: receiver  ( err pbuf pcb arg -- err )
   drop  to fts-pcb  nip        ( pbuf )
   ?dup 0=  if                  ( pbuf )
      fts-pcb close-connection  ( )
      close-fid
      ERR_OK
      exit                      ( -- err )
   then                         ( pbuf )
   dup pbuf>len                 ( pbuf adr thislen totlen )
   fts-pcb tcp-recved           ( pbuf adr thislen )
   $rx                          ( pbuf )
   pbuf-free drop               ( )
   ERR_OK                       ( err )
;

: accepter     ( err new-pcb arg -- err )
   drop >r                     ( err r: new-pcb )
   ?dup  if                    ( err r: new-pcb )
      r> drop                  ( err )
      ." Accept error " .d cr  ( )
      ERR_ABRT
      exit
   then                        ( )
   fts-listen-pcb tcp-accepted
   ['] receiver r@ tcp-recv
   r@ to fts-pcb
   \ FIXME: state should be held per connection
   \ ['] $rx-cmd r@ tcp-arg
   ['] $rx-cmd to $rx
   r> drop
   ERR_OK                      ( err )
;

: fts-off  ( -- )
   fts-listen-pcb  ?dup  if  tcp-close drop  0 to fts-listen-pcb  then
;

: fts-on  ( -- )
   fts-off
   tcp-new    ( pcb )
   #7430 inet-addr-any  2 pick  tcp-bind  abort" Bind failed"  ( pcb )
   1 swap tcp-listen-backlog  to fts-listen-pcb
   ['] accepter fts-listen-pcb tcp-accept   ( )
;

previous definitions  also fts-v

: fts  fts-on  ;
: fts-off  fts-off  ;

previous
