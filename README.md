# **C Forth based firmware for ESP8266 WiFi SOC** #

A fork of C Forth with my own improvements;

 * trim Open Firmware so the build will fit on an ESP-01,
 * run a script from the filesystem on boot,
 * a file transfer server,
 * a telnet server.

## Boot script ##

How to set up a script to say hello world on boot.


```
" init.fth" create-fid
" ."(22) hello world"(22) cr"n" write-fid
close-fid
bye

```

## Timers ##

How to test timers.


```
: (cb0) ." alarm 0" cr ;
: (cb1) ." alarm 1" cr ;
: (cb2) ." alarm 2" cr ;

' (cb0) new-timer value t0
' (cb1) new-timer value t1
' (cb2) new-timer value t2

#5000 1 1 t1 arm-timer
#1000 1 1 t0 arm-timer
#2000 1 1 t2 arm-timer

t0 disarm-timer
t1 disarm-timer
t2 disarm-timer

```

## GPIO ##

How to use GPIO pins.

### Fundamentals ###

Create constants for pin numbers.  See NodeMCU for mapping.

```
3 constant g0
4 constant g2

pullup gpio-output g0 gpio-mode

1 g0 gpio-pin!

pullup gpio-input g0 gpio-mode

g0 gpio-pin@ .
```

### Example; timer based flashing LED blinky ###

```
3 constant g0
0 value my-timer
#100 value period

: change
   g0 gpio-pin@ 0= g0 gpio-pin!
;

: init
   pullup gpio-output g0 gpio-mode
   ['] change new-timer to my-timer
   period 1 1 my-timer arm-timer
;

: deinit
   my-timer disarm-timer
   pullup gpio-input g0 gpio-mode
;
```

### Example; detect a falling edge button with a falling edge interrupt ###

```
3 constant g0

: disarm  ( -- )        gpio-int-disable g0 gpio-enable-interrupt  ;
: rearm   ( -- )        gpio-int-negedge g0 gpio-enable-interrupt  ;
: fall    ( level -- )  drop  ." button pressed" cr  rearm  ;

: init
   pullup gpio-interrupt g0 gpio-mode
   ['] fall g0 gpio-callback!  rearm
;

: deinit
   gpio-int-disable g0 gpio-enable-interrupt
;
```

### Example; debounce a falling edge button with timer ###

Used dictionary space; 464 bytes.

```
3 constant g0
0 value b-timer
#5 value b-ms
0 value b-count
0 value b-state

: b-cb
   g0 gpio-pin@ if
      b-count 6 = if
         b-state if
            ." up" cr
         then
         0 to b-state
      else
         b-count 1+ to b-count
      then
   else
      b-count 0= if
         b-state 0= if
            ." down" cr
         then
         1 to b-state
      else
         b-count 1- to b-count
      then
   then
;

: init
   pullup gpio-input g0 gpio-mode
   ['] b-cb new-timer to b-timer
   b-ms 1 1 b-timer arm-timer
;

: deinit
   b-timer disarm-timer
;
```

### Example; debounce a falling edge button with edge triggered interrupt ###

Used dictionary space; 288 bytes.

```
3 constant g0
0 value saved
#50000 constant delay  \ debounce time in microseconds

: any  ( level -- )
   get-ticks dup saved -                ( level ticks delta )
   delay  u<  if  2drop exit  then      ( level ticks )
   to saved                             ( level )
   0= if                                ( )
      ." button pressed at " saved .d cr
   then
;

: init
   pullup gpio-input g0 gpio-mode
   ['] any g0 gpio-callback!
   gpio-int-anyedge g0 gpio-enable-interrupt
;

: deinit
   gpio-int-disable g0 gpio-enable-interrupt
;

```

## Connecting to a wireless access point ##

```
wifi-sta-connect@ .

1 wifi-opmode!

create sta-config 67 allot

: cstr!  ( src srclen dst dstlen -- )
   2dup erase   ( src srclen dst dstlen )
   drop         ( src srclen dst )
   swap         ( src dst srclen )
   move         ( )
;

: sta-config@  ( -- )
   sta-config wifi-sta-config@ drop
;

: sta-config!  ( password$ ssid$ -- )
   sta-config #32 cstr!         ( password$ )
   sta-config #32 + #64 cstr!   ( )
   0 sta-config #96 + c!        \ bssid_set
   sta-config #97 + 6 erase     \ bssid
   sta-config wifi-sta-config! 0= abort" sta-config!"
;

: .sta-config
   ." ssid = " sta-config cscount type cr
   ." password = " sta-config #32 +  cscount type cr
   sta-config #96 +  c@  if
      ." bssid_set = 1" cr
      ." bssid = " sta-config #97 + 6 cdump cr
   then
;

sta-config@
" " " qz" sta-config!

wifi-sta-connect

: sta-ipaddr@  ( -- )   pad 0 wifi-ip-info@ drop  pad  ;
: .sta-ipaddr  ( -- )   sta-ipaddr@  .ipaddr  ;

0 value my-timer
: (cb)
   wifi-sta-connect@ 5 <> if
      ." Connecting..." cr
   else
      ." Connected, IP is "  .sta-ipaddr cr
      my-timer disarm-timer
   then
;
' (cb) new-timer to my-timer

#1000 1 1 my-timer arm-timer

wifi-sta-connect

```

## HTTP client ##

```
: receiver  ( err pbuf pcb arg -- err )
   ." [receiver] " .s cr
   drop  to rx-pcb  nip         ( pbuf )
   ?dup 0=  if                  ( )
      ." [connection closed by remote host]" cr
      close-fid
      rx-pcb close-connection   ( )
      0 to rx-pcb
      ERR_OK
      exit                      ( -- err )
   then                         ( pbuf )
   dup pbuf>len                 ( pbuf adr len totlen )
   rx-pcb tcp-recved            ( pbuf adr len )
   write-fid                    ( pbuf )
   pbuf-free drop               ( )
   ERR_OK                       ( err )
   ." [/receiver] " .s cr
;

: sent-handler  ( len pcb arg -- err )
   ." [sent] " .s cr
   3drop  ERR_OK
;

: error-handler  ( err arg -- )
   ." [error] " swap .d " with arg " .d cr
;

: connected  ( err pcb arg -- err )
   ." [connected] " .s cr
   drop >r           ( err r: pcb )
   ?dup  if          ( err r: pcb )
      r> drop        ( err )
      ." [connect error] " .d cr  ( )
      ERR_VAL exit
   then              ( )
   ['] receiver r@ tcp-recv
   ['] error-handler r@ tcp-err
   ['] sent-handler r@ tcp-sent

   " GET /index.html HTTP/1.0"(0A)"(0A)" r@ tcp-write drop

   r> drop           ( )
   ERR_OK
   ." [/connected] " .s cr
;

: unclient  ( -- )
   rx-pcb  ?dup  if  tcp-close drop  0 to rx-pcb  then
;

create ip  d# 10 c, 0 c, 0 c, 3 c,

: client  ( -- )
   ." [client] " .s cr
   unclient  tcp-new to rx-pcb
   ." [client] rx-pcb is " rx-pcb . cr
   " index.html" create-fid
   #0 inet-addr-any rx-pcb tcp-bind  abort" Bind failed"
   ['] connected #80 ip rx-pcb tcp-connect  abort" Connect failed"
   ." [/client] " .s cr
;

\ client

```

