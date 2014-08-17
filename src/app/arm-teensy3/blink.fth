
[ifndef] ms
: ms  ( ms -- )
   get-msecs +
   begin
      dup get-msecs - 0<
   until
   drop
;
[then]

\ ports, each with 32 pins
h# 0 constant port-a#
h# 1 constant port-b#
h# 2 constant port-c#
h# 3 constant port-d#
h# 4 constant port-e#

\ pin control registers
h# 4004.9000 constant pcr-base

\ size of a port's pin control registers
h# 1000 constant /pcr-port

\ pin control register (per port and pin)
: port.pin>pcr  ( port# pin# -- pcr )  4 *  swap  /pcr-port *  pcr-base +  +  ;

\ global pin control register (per port)
: port>gpcr  ( port# -- gpcr.d' )  /pcr-port *  pcr-base +  h# 80  +  ;

\ pin control register bits
: +af1  h# 0000.0100 or  ;  \ mux, pin mux control, alternative 1
: +dse  h# 0000.0040 or  ;  \ dse, drive strength enable, high
: +ode  h# 0000.0020 or  ;  \ ode, open drain enable, enabled

\ pin control register access
: pcr!  ( mask port# pin# -- )  port.pin>pcr  !  ;
: pcr@  ( port# pin# -- mask )  port.pin>pcr  @  ;

\ gpio registers
h# 400f.f000 constant gpio-base

\ convert port and pin to mask and gpio register
: port.pin>mask.gpio  ( port# pin# -- mask gpio )
   1 swap shift         ( port# mask )
   swap                 ( mask port# )
   h# 40 * gpio-base +  ( mask gpio )
;

\ gpio access
: gpio-set  ( port# pin# -- )  port.pin>mask.gpio  h# 04 +  !  ;
: gpio-clr  ( port# pin# -- )  port.pin>mask.gpio  h# 08 +  !  ;
: gpio-toggle  ( port# pin# -- )  port.pin>mask.gpio  h# 0c +  !  ;
: gpio-pin@  ( port# pin# -- flag  )
   port.pin>mask.gpio   ( mask gpio )
   h# 10 + @ and 0<>    ( flag )
;
: gpio-dir-out  ( port# pin# -- )
   port.pin>mask.gpio   ( mask-to-set gpio )
   dup >r               ( mask-to-set gpio      r: gpio )
   @                    ( mask-to-set mask-now  r: gpio )
   or                   ( mask-new              r: gpio )
   r> h# 14 + !         ( )
;
: gpio-dir-in  ( port# pin# -- )  \ fixme
   port.pin>mask.gpio   ( mask-to-clr gpio )
   dup >r               ( mask-to-clr gpio      r: gpio )
   @                    ( mask-to-clr mask-now  r: gpio )
   swap invert and      ( mask-new              r: gpio )
   r> h# 14 + !         ( )
;
: gpio-out?  ( port# pin# -- out? )
   port.pin>mask.gpio   ( mask gpio )
   h# 14 + @ and 0<>    ( flag )
;

\ Teensy 3.1 has LED to ground on pin PTC5
: led-gpio##  ( port# pin# -- )  port-c#  5  ;

: led-init
   0 +af1 +dse  led-gpio##  pcr!
   led-gpio##  gpio-dir-out
;

: led-on      led-gpio##  gpio-set     ;
: led-toggle  led-gpio##  gpio-toggle  ;
: led-off     led-gpio##  gpio-clr     ;

: blink
   led-init
   begin
      led-on  d# 100 ms  led-off  d# 900 ms
      key?
   until
;
