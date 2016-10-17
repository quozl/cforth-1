\ telnetd

vocabulary telnetd-v
also telnetd-v definitions

warning off

0 value telnetd-pcb
0 value telnetd-listen-pcb

: tcp-write-bare  ( adr len -- )
   telnetd-pcb tcp-write drop
;

: evaluate-throw  ( adr len -- )
   evaluate  -98 throw
;

: commander  ( adr len -- )
   ['] tcp-write-bare to reply-send
   reply{  ['] evaluate-throw  catch  drop 2drop  prompt  }reply
;

: receiver  ( err pbuf pcb arg -- err )
   drop  to telnetd-pcb  nip    ( pbuf )
   ?dup 0=  if                  ( )
      telnetd-pcb close-connection
      ERR_OK exit               ( -- err )
   then                         ( pbuf )
   dup pbuf>len                 ( pbuf adr len totlen )
   telnetd-pcb tcp-recved       ( pbuf adr len )
   rot >r                       ( adr len r: pbuf )  \ hide my stack
   commander                    ( r: pbuf )
   r>                           ( pbuf )
   pbuf-free drop               ( )
   ERR_OK                       ( err )
;

: accepter  ( err new-pcb arg -- err )
   drop >r                     ( err r: new-pcb )
   ?dup  if                    ( err r: new-pcb )
      r> drop                  ( err )
      drop                     ( )
      ERR_ABRT
      exit
   then                        ( )
   telnetd-listen-pcb tcp-accepted
   ['] receiver r@ tcp-recv
   r@ to telnetd-pcb
   r> drop
   ['] tcp-write-bare to reply-send
   reply{  banner prompt  }reply
   ERR_OK                      ( err )
;

: telnetd-off  ( -- )
   telnetd-listen-pcb  ?dup  if  tcp-close drop  0 to telnetd-listen-pcb  then
;

: telnetd-on  ( -- )
   telnetd-off
   tcp-new    ( pcb )
   #23 inet-addr-any  2 pick  tcp-bind  abort" Bind failed"  ( pcb )
   1 swap tcp-listen-backlog  to telnetd-listen-pcb
   ['] accepter telnetd-listen-pcb tcp-accept   ( )
;

previous definitions  also telnetd-v

: telnetd  telnetd-on  ;
: telnetd-off  telnetd-off  ;

previous
