\ a line-based telnetd

warning off

: telnetd-send  ( adr len -- )
   rx-pcb tcp-write     ( stat )
   ?dup  if             ( stat )
      " tcp-write returned " .d cr
   then                 ( )
;

' telnetd-send to reply-send

: evaluate-throw  ( adr len -- )  evaluate -98 throw  ;

: commander  ( adr len -- )
   reply{
   ['] evaluate-throw  catch  drop 2drop  \ protect my stack
   prompt
   }reply
;

: receiver  ( err pbuf pcb arg -- err )
   drop  to rx-pcb  nip         ( pbuf )
   ?dup 0=  if                  ( pbuf )
      ." [connection closed by remote host]" cr
      rx-pcb close-connection   ( )
      ERR_ABRT
      exit                      ( -- err )
   then                         ( pbuf )
   dup pbuf>len                 ( pbuf totlen  adr len )
   rot rx-pcb tcp-recved        ( pbuf adr len )
   rot >r                       ( adr len r: pbuf )  \ hide my stack
   commander                    ( r: pbuf )
   r>                           ( pbuf )
   pbuf-free drop               ( )
   ERR_OK                       ( err )
;

0 value listen-pcb

: accepter     ( err new-pcb arg -- err )
   drop >r                     ( err r: new-pcb )
   ?dup  if                    ( err r: new-pcb )
      r> drop                  ( err )
      ." Accept error " .d cr  ( )
      exit
   then                        ( )
   listen-pcb tcp-accepted
   ['] receiver r@ tcp-recv
   r@ to rx-pcb
   r> drop
   ." [connection accepted]" cr
   reply{ banner prompt }reply
   ERR_OK                      ( err )
;

: unlisten  ( -- )
   listen-pcb  ?dup  if  tcp-close drop  0 to listen-pcb  then
;

: listen  ( -- )
   unlisten
   tcp-new    ( pcb )
   #23 inet-addr-any  2 pick  tcp-bind  abort" Bind failed"  ( pcb )
   1 swap tcp-listen-backlog  to listen-pcb
   ['] accepter listen-pcb tcp-accept   ( )
;
