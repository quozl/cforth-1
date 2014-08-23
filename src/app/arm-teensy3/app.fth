\ Load file for application-specific Forth extensions

fl ../../lib/misc.fth
fl ../../lib/dl.fth

#0 ccall: spins       { i.nspins -- }
#1 ccall: wfi         { -- }
#2 ccall: get-msecs   { -- n }
#3 ccall: a@          { i.pin -- n }
#4 ccall: p!          { i.val i.pin -- }
#5 ccall: p@          { i.pin -- n }
#6 ccall: m!          { i.mode i.pin -- }
#7 ccall: get-usecs   { -- n }
#8 ccall: delay       { n -- }
#9 ccall: bye         { -- }
#10 ccall: /eeprom       { -- n }
#11 ccall: eeprom-base   { -- n }
#12 ccall: eeprom-length { -- n }
#13 ccall: eeprom@   { i.adr -- i.val }
#14 ccall: eeprom!   { i.val i.adr -- }

fl ../../platform/arm-teensy3/watchdog.fth
fl ../../platform/arm-teensy3/timer.fth
fl ../../platform/arm-teensy3/pcr.fth
fl ../../platform/arm-teensy3/gpio.fth

d# 13 value d13
d# 14 value d14

: be-in      0 swap m!  ;
: be-out     1 swap m!  ;
: be-pullup  2 swap m!  ;

: go-on      1 swap p!  ;
: go-off     0 swap p!  ;

: wait       d# 125 ms  ;

: lb
   d13 be-out  d14 be-out
   begin
      d13 go-on  wait  d13 go-off
      d14 go-on  wait  d14 go-off
      key?
   until
;

\ eeprom for source code
: .d%  ( n -- )  push-decimal  (.) type [char] % emit  pop-base  ;
: .usage  ( -- )  eeprom-length d# 100 * /eeprom / .d%  ;
: eeprom-clear  ( -- )  0 0 eeprom!  ;
: eeprom$  ( -- adr len )  eeprom-base eeprom-length  ;
: .eeprom  ( -- )  eeprom$ type  ;
: eeprom-dump  ( -- )  eeprom$ 1+ cdump  ;
: eeprom-dump-all  ( -- )  eeprom-base /eeprom dump  ;
: eeprom-evaluate  ( -- )
   eeprom$  ['] evaluate  catch  ?dup  if  3drop  then
;
defer init  ' noop is init
: ^  ( text ( )
   eeprom-length        ( pos )
   eol parse            ( pos adr len )
   bounds do            ( pos )
      i c@ over         ( pos char pos )
      eeprom!           ( pos )
      1+                ( pos+1 )
   loop                 ( pos+len )
   h# a over eeprom!    ( pos+len+1 )
   1+ 0 swap eeprom!    ( )
;

: app
   eeprom-evaluate  init
   ." CForth" cr hex quit
;

" app.dic" save
